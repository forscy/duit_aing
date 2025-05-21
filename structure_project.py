import os
import argparse
from pathlib import Path
import sys

def list_directory_structure(directories, output_file=None):
  """
  List all files within specified directories including subdirectories.
  
  Args:
    directories (list): List of directory paths to scan
    output_file (file object, optional): File to write output to
  """
  original_stdout = sys.stdout
  if output_file:
    sys.stdout = output_file
    
  try:
    for directory in directories:
      path = Path(directory)
      if not path.exists() or not path.is_dir():
        print(f"Directory not found: {directory}")
        continue
          
      print(f"\n{'='*50}")
      print(f"Files in {directory}:")
      print(f"{'='*50}")
      
      for root, dirs, files in os.walk(directory):
        level = root.replace(directory, '').count(os.sep)
        indent = ' ' * 4 * level
        print(f"{indent}{os.path.basename(root)}/")
        sub_indent = ' ' * 4 * (level + 1)
        for file in files:
          print(f"{sub_indent}{file}")
  finally:
    if output_file:
      sys.stdout = original_stdout


def main():
  parser = argparse.ArgumentParser(description='List files in specified directories')
  parser.add_argument('directories', nargs='*', default=['lib', 'docs'], 
            help='Directories to scan (default: lib and docs)')
  parser.add_argument('--output', default='docs/structure_project.txt',
            help='Output file path (default: docs/structure_project.txt)')
  
  args = parser.parse_args()
  
  # Create output directory if it doesn't exist
  output_path = Path(args.output)
  output_path.parent.mkdir(parents=True, exist_ok=True)
  
  with open(args.output, 'w') as f:
    list_directory_structure(args.directories, f)
    print(f"Structure saved to {args.output}")


if __name__ == "__main__":
  main()