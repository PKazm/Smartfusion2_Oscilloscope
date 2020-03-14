import pdb
import math

data_width = 8
N_exp = 8

def main():
    get_param_input()
    do_adc_smpl_gen()

#==============================================================================
def get_param_input():
    global data_width
    global N_exp
    data_width = int(input('Data Width (2 < natural < 32): '))
    N_exp = int(input('N^exp; (2 < exp < 16): '))
#==============================================================================
def do_adc_smpl_gen():
    file = open('ADC_samples.vhd', 'w')
    print(file.name)

    N = 2**(N_exp)
    file.write('hello\n')

    for i in range(0, N):
        file.write('std_logic_vector(to_unsigned(')
        sin_value = math.sin(2*math.pi*5*i/N)
        sin_val_rnd = round(sin_value * (2 ** (data_width - 1) - 1) + (2 ** (data_width - 1) - 1))
        file.write(str(sin_val_rnd) + ', 8)),\n')

    file.close()

main()