import os
import sys
import re
from glob import glob
from datetime import datetime


def fix_time(path, time):
  os.utime(path, (time, time))

def get_name(name):
  return re.sub('^@?!|(?:-resize)?\.(?:jpg|png|webp|bmp)$', '', name)

def parse_index(path):
  indexes = {}
  with open(path) as fp:
    while line := fp.readline():
      name, _, _, time = line.strip().split('\t')
      indexes[get_name(name)] = datetime.fromisoformat(time).timestamp()
  return indexes

def fix_time_dir(path):
  cwd = os.getcwd()
  os.chdir(path)
  indexes = parse_index('~source.filestats.tsv')
  for file in glob('*.jpg') + glob('*.png'):
    time = indexes[get_name(file)]
    fix_time(file, time)
    print(file)
  os.chdir(cwd)


for dir in sys.argv[1:]:
  fix_time_dir(dir)
