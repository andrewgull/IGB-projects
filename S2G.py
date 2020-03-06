#!/usr/bin/python3

"""
Created on Mon Mar 13 17:09:34 2017
@author: andrew
"""

import sys


def read_fasta(filename):
    """
    reads fasta filename
    :param filename: a name of the file to read
    :return dictionary name:sequence
    """
    try:
        f = open(filename)
    except IOError:
        print("File %s not found!" % filename)
        sys.exit()

    seqs = {}
    for line in f:
        line = line.rstrip()
        if line[0] == ">":
            # words = line.split()
            # name = words[0][1:]
            name = line[1:]
            seqs[name] = ""
        else:
            seqs[name] = seqs[name] + line
    f.close()
    return seqs


def read_scheme(filename):
    """
    reads scheme file
    :return: scheme file as a dict of dicts
    """
    try:
        f = open(filename)
    except IOError:
        print("File %s not found!" % filename)
        sys.exit()
    scheme_list = [line.rstrip() for line in f]
    scheme_list = [item.split(";") for item in scheme_list]
    # make dictionary
    scheme_dict = {}
    for i in range(len(scheme_list)):
        genotype = "genotype" + str(i+1)
        int_dict = {}
        for item in scheme_list[i]:
            alleles = item.split(" ")
            int_dict[alleles[0]] = list(map(lambda x: int(x), alleles[1:]))
        scheme_dict[genotype] = int_dict
    return scheme_dict


def write_fasta(filename, fasta_dict):
    """
    function to write fasta file from a dictionary name:sequence
    :param filename: output file name
    :param fasta_dict: a dict name:sequence from read_fasta()
    :return: nothing
    """
    names = list(fasta_dict.keys())
    names.sort()
    # make list of type [name1, sequence1, name2, sequence2]
    fasta_list = list()
    for name in names:
        fasta_list.append(name)
        fasta_list.append(fasta_dict[name])

    # write to a file
    with open(filename, "w") as f:
        for seq in fasta_list:
            if fasta_list.index(seq) % 2 == 0:
                f.write(">%s\n" % seq)
            else:
                f.write("%s\n" % seq)


def make_genotypes(scheme, alleles, spacer):
    """
    :param scheme: a dict of dicts representing genotype schemes
    :param alleles: a dict name:sequence
    :param spacer: character to use as spacer
    :return:
    """
    # for each genotype
    # genotype_list = list()
    genotype_dict = dict()
    for genotype in scheme.keys():
        genot = scheme[genotype]
        # concatenate first loci of each allele
        allele_names1 = [loci + ' ' + str(genot[loci][0]) for loci in genot.keys()]
        allele_names1.sort()
        upline = ''
        for name in allele_names1:
            upline += alleles[name] + spacer
        genotype_dict[genotype] = upline

        # concatenate second loci of each allele
        allele_names2 = [loci + ' ' + str(genot[loci][1]) for loci in genot.keys()]
        allele_names2.sort()
        downline = ''
        for name in allele_names2:
            downline += alleles[name] + spacer
        genotype_dict[genotype+"_"] = upline
    return genotype_dict

msg = "A program for concatenating satellites into genotypes\n" \
      "Arguments:\n" \
      "1 - genotypes scheme file\n" \
      "2 - alleles file (in FASTA format)"

if len(sys.argv) < 2:
    print(msg)
    sys.exit()

scheme_file = sys.argv[1]
fasta_file = sys.argv[2]
# read scheme file
# scheme = json.loads(open(scheme_file).readline())
scheme = read_scheme(scheme_file)

# make alleles dict
satellites = read_fasta(fasta_file)
genotype_seqs = make_genotypes(scheme, satellites, spacer="---")
write_fasta("genomes.fasta", genotype_seqs)
print("Done!")
