#!/usr/bin/python3
import sys,os,os.path,argparse,collections

##########################################################################
##########################################################################

def print_table(f,columns,rows):
    widths=[0]*len(columns)

    def update_widths(parts):
        assert len(parts)==len(widths)
        for i in range(len(parts)): widths[i]=max(widths[i],len(parts[i]))

    update_widths(columns)
    for row in rows: update_widths(row)

    def print_row(parts):
        for i in range(len(parts)): f.write('| %-*s '%(widths[i],parts[i]))
        f.write('|\n')

    print_row(columns)
    for i in range(len(widths)): f.write('|%s'%((widths[i]+2)*'-'))
    f.write('|\n')
    for row in rows: print_row(row)

def main2(options):
    def get_ics_str(ics): return ', '.join(['IC%d'%ic for ic in ics])

    stem='docs/table'
    
    def b():
        def region(name,ic):
            rows=[]
            for value in range(1,256):
                ics=[]
                for i in range(8):
                    if value&1<<i: ics.append(ic+i)
                rows.append(['%02X'%value,get_ics_str(ics)])
            with open('%s.b.%s.md'%(stem,name),'wt') as f:
                print_table(f,['Value','IC(s)'],rows)
        region('L',61)
        region('H',53)
        
    def bplus():
        rows=[]
        for value in range(1,256):
            ics=[]
            for i in range(8):
                if value&1<<i: ics.append([55,56,60,61,64,65,66,67][i])
            rows.append(['%02X'%value,get_ics_str(ics)])

        with open('%s.bplus.md'%stem,'wt') as f:
            print_table(f,['Value','IC(s)'],rows)

    def master(type,m0123,m4567,s0123,s4567):
        def region(name,ic0123,ic4567):
            rows=[]
            for value in range(1,256):
                ics=[]
                if (value&0x0f)!=0: ics.append(ic0123)
                if (value&0xf0)!=0: ics.append(ic4567)
                rows.append(['%02X'%value,get_ics_str(ics)])
            with open('%s.%s.%s.md'%(stem,type,name),'wt') as f:
                print_table(f,['Value','IC(s)'],rows)

        region('M',m0123,m4567)
        region('S',s0123,s4567)

    def master_128(): master('master_128',23,17,26,18)
    def master_compact(): master('master_compact',35,41,36,47)
    
    b()
    bplus()
    master_128()
    master_compact()

def main(argv):
    main2(None)

##########################################################################
##########################################################################

if __name__=='__main__': main(sys.argv[1:])
