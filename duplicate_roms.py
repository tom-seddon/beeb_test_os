#!/usr/bin/python3
import os,os.path,sys,argparse,glob

##########################################################################
##########################################################################

def fatal(msg):
    sys.stderr.write('FATAL: %s\n'%msg)
    sys.exit(1)

##########################################################################
##########################################################################

def main2(options):
    paths=[]
    for path in options.paths: paths+=glob.glob(path)

    roms=[]
    for path in paths:
        with open(path,'rb') as f:
            data=f.read()
            if len(data)>16384: fatal('ROM larger than 16 KB: %s'%path)
            if len(data)<16384: data+=bytes(16384-len(data))
                
            roms.append(data)

    for size in options.sizes:
        if size not in [16,32,64,128]: fatal('invalid ROM size: %s'%size)
        # resized_roms=[]
        # for rom in roms: resized_roms.append((size//16)*rom)

        if options.output_path is not None:
            output_path=os.path.join(options.output_path,'%d'%size)
            if not os.path.isdir(output_path): os.makedirs(output_path)
            for i in range(len(roms)):
                with open(os.path.join(output_path,
                                       os.path.split(paths[i])[1]),
                          'wb') as f:
                    f.write((size//16)*roms[i])

    # print(paths)
    # print(options.sizes)

##########################################################################
##########################################################################

def auto_int(x): return int(x,0)

def main(argv):
    parser=argparse.ArgumentParser()
    parser.add_argument('-o',dest='output_path',metavar='FOLDER',help='''output stuff to %(metavar)s''')
    parser.add_argument('-n',dest='sizes',type=auto_int,action='append',metavar='SIZE',help='''make up some %(SIZE) KB ROMs and write to folder called %(SIZE) in output folder (if specified)''')
    parser.add_argument('paths',nargs='+',metavar='FILE',help='''read ROM(s) from %(metavar)s. Glob patterns will be expanded on Windows''')
    main2(parser.parse_args(argv))

##########################################################################
##########################################################################

if __name__=='__main__': main(sys.argv[1:])
