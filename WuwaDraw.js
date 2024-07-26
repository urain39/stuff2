class DrawMachine {
  constructor() {
    this.count = 0;
    this.guaranteed = false;
  }

  draw(n) {
    let p, count;
    for (let i = 0; i < n; i++) {
      count = ++this.count;
      if (count >= 1 && count <= 70)
        p = 0.008;
      else {
        p = (count - 70) * 0.1 + 0.008;
        //p = p > 1 ? 1 : p;
      }
      if (Math.random() < p) {
        this.count = 0;
        if (this.guaranteed || Math.random() < 0.5) {
          this.guaranteed = false;
          return i;
        } else this.guaranteed = true;
      }
    }
    return 0;
  }
}

new DrawMachine().draw(160);
