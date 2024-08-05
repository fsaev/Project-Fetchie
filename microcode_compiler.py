import json
import argparse



def parse_json(json_file):
    with open(json_file, 'r') as f:
        return json.load(f)
    
def compile_microcode(microcode_def):

    
def main():
    # Args
    parser = argparse.ArgumentParser(
        description='Fetchie Microcode Compiler',
        epilog='Example: python3 microcode_compiler.py /path/to/json')
    parser.add_argument('filename', nargs='?', metavar='/path/to/json',
                        help='Path to JSON file')
    parser.add_argument('--version', action='store_true',
                        help='Print version info')
    args = parser.parse_args()

    if args.version:
        print('Fetchie Microcode Compiler v0.1 - (C) fsaev 2024')
        return

    json_file = args.filename
    microcode_def = parse_json(json_file)
    print(microcode_def)
    
if __name__ == '__main__':
    main()