import scipy.sparse
import scipy.io
import numpy
import os
import pickle


import struct
import argparse

def crange(modulo):
    i = 0
    while True:
        yield i
        i += 1
        if i == modulo:
            i = 0

def splitters(num_els, num_parts):
    avg = num_els / float(num_parts)
    last = 0.0
    while last < num_els:
        yield int(last)
        last += avg
    yield num_els

parser = argparse.ArgumentParser(description='Convert a MatrixMarket matrix (from e.g. sparse.tamu.edu) into binary files for execution on FPGA.')
parser.add_argument('-v', '--vec', action='store_true', help='Also generate a random vector with as many rows as the columns of the matrix')
parser.add_argument('-a', '--acc', type=str, help='Number of accelerators among which the matrix is partitioned. Use a..b (ex. 1..4) to generate for a range of accelerator numbers (both start and end inclusive).', default='1')
parser.add_argument('-i', '--interleaved', action='store_true', help='Partition rows across accelerators in an interleaved manner. If disabled, rows are partitioned in blocks (contiguous rows are given to the same accelerator).')
parser.add_argument('-s', '--split', action='store_true', help='Split val and col_ind into two separate files', default=False)
parser.add_argument('input_file', help='Input MatrixMarket file (*.mtx or as a CSR *.pickle)')
args=parser.parse_args()

file_name_no_ext = os.path.splitext(args.input_file)[0]
file_ext = os.path.splitext(args.input_file)[1]
if file_ext == '.mtx':
    matrix = scipy.io.mmread(args.input_file).tocsr()
    pickle_file = file_name_no_ext + '.pickle'
    with open(pickle_file, 'wb') as fh:
        pickle.dump(matrix, fh)
elif file_ext == '.pickle':
    with open(args.input_file, 'rb') as f:
        matrix = pickle.load(f)
else:
    raise RuntimeError('input_file must either be an .mtx or a .pickle file.')
print("Imported {} matrix with {} non-zero elements\n".format(matrix.shape, len(matrix.data)))
if args.interleaved:
    root_folder_name = os.path.splitext(os.path.basename(args.input_file))[0][0:8]
else:
    root_folder_name = os.path.splitext(os.path.basename(args.input_file))[0][0:7] + 'b'
acc_range = [int(x) for x in args.acc.split('..')]
if len(acc_range) == 0:
    acc_range.append(acc_range[0])
for acc_count in range(acc_range[0], acc_range[1]+1):
    full_folder_path = os.path.join(root_folder_name, str(acc_count))
    os.makedirs(full_folder_path, exist_ok=True)
    print("Creating folder {}\n".format(full_folder_path))

    interleaved_rowptr = [[0] for i in range(acc_count)]
    interleaved_data = [[] for i in range(acc_count)]
    interleaved_col_ind = [[] for i in range(acc_count)]

    data_list = matrix.data.tolist()
    indices_list = matrix.indices.tolist()

    if args.interleaved:
        for curr_acc, start, end in zip(crange(acc_count), matrix.indptr, matrix.indptr[1:]):
            count = end - start
            interleaved_rowptr[curr_acc].append(interleaved_rowptr[curr_acc][-1] + count)
            interleaved_data[curr_acc] += data_list[start:end]
            interleaved_col_ind[curr_acc] += indices_list[start:end]
    else:
        spl = [x for x in splitters(len(matrix.indptr), acc_count)]
        interleaved_rowptr = [matrix.indptr[x:y + 1] for x, y in zip(spl, spl[1:])]
        interleaved_data = [matrix.data[x[0]:x[-1]] for x in interleaved_rowptr]
        interleaved_col_ind = [matrix.indices[x[0]:x[-1]] for x in interleaved_rowptr]

    interleaved_rowptr = [[val-row[0] for val in row] for row in interleaved_rowptr]
    vect = numpy.random.rand(matrix.shape[1])

    res = matrix * vect

    split_matrices = [scipy.sparse.csr_matrix((numpy.array(interleaved_data[i]), numpy.array(interleaved_col_ind[i]), numpy.array(interleaved_rowptr[i])), (len(interleaved_rowptr[i])-1, matrix.shape[1])) for i in range(acc_count)]

    for acc, this_rowptr, this_data, this_cols in zip(range(acc_count), interleaved_rowptr, interleaved_data, interleaved_col_ind):
        if args.split:
            val_file_name = '{}.val'.format(acc)
            print("Creating file {}\n".format(os.path.join(full_folder_path, val_file_name)))
            with open(os.path.join(full_folder_path, val_file_name), 'wb') as f:
                f.write(struct.pack("I", len(this_data)))
                for val in this_data:
                    f.write(struct.pack("f", val))
            col_file_name = '{}.col'.format(acc)
            print("Creating file {}\n".format(os.path.join(full_folder_path, col_file_name)))
            with open(os.path.join(full_folder_path, col_file_name), 'wb') as f:
                f.write(struct.pack("I", len(this_data)))
                for col in this_cols:
                    f.write(struct.pack("I", col))
        else:
            val_col_file_name = '{}.dat'.format(acc)
            print("Creating file {}\n".format(os.path.join(full_folder_path, val_col_file_name)))
            with open(os.path.join(full_folder_path, val_col_file_name), 'wb') as f:
                f.write(struct.pack("I", len(this_data)))
                for val, col in zip(this_data, this_cols):
                    # f.write('{:x}'.format(struct.unpack("I", struct.pack("f", val))[0]) + ' ' + str(col) + '\n')
                    f.write(struct.pack("fI", val, col))

        row_ptr_file_name = '{}.row'.format(acc)
        print("Creating file {}\n".format(os.path.join(full_folder_path, row_ptr_file_name)))
        with open(os.path.join(full_folder_path, row_ptr_file_name), 'wb') as f:
            f.write(struct.pack("I", len(this_rowptr)))
            for rowptr in this_rowptr:
                # f.write(str(rowptr) + '\n')
                f.write(struct.pack("I", rowptr))

    if args.vec:
        print("Generating random vector of size {}\n".format(matrix.shape[1]))
        vect = numpy.random.rand(matrix.shape[1])

        vect_file_name = '{}.vec'.format(root_folder_name)
        print("Creating file {}\n".format(os.path.join(full_folder_path, vect_file_name)))
        with open(os.path.join(full_folder_path, vect_file_name), 'wb') as f:
            f.write(struct.pack("I", matrix.shape[1]))
            for val in vect:
                # f.write('{:x}'.format(struct.unpack("I", struct.pack("f", val))[0]) + '\n')
                f.write(struct.pack("f", val))

        res = matrix * vect
        split_res = [mat * vect for mat in split_matrices]
        for acc, this_res in enumerate(split_res):
            res_file_name = '{}.exp'.format(acc)
            print("Creating file {}\n".format(os.path.join(full_folder_path, res_file_name)))
            with open(os.path.join(full_folder_path, res_file_name), 'wb') as f:
                f.write(struct.pack("I", len(this_res)))
                for val in this_res:
                    f.write(struct.pack("f", val))
