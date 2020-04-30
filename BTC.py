import os
import BTNP


def walk(dir_):
  def walk_(dir__):
    print(dir__)
    for i in os.listdir(dir__):
      if os.path.isfile(i) and not i.endswith(".aria2"):
        try:
          r = BTNP.parse(i)
          try:
            dn = os.path.join(dir_, r["category"], r["group_author"])
            os.makedirs(dn, exist_ok=True)
            on = os.path.join(dir__, i)
            nn = os.path.join(dn, r["file_name"])
            if os.path.isfile(on + ".aria2"):
              print(f"Skip {on}, due to it is unfinished.")
              continue
            os.rename(on, nn)
          except TypeError:
            pass
        except AttributeError:
          pass
      #elif os.path.isdir(i):
      #  walk_(os.path.join(dir__, i))
      else:
        pass
  walk_(dir_)


walk(".")
