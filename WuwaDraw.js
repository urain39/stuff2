class DrawMachine {
  constructor() {
    this.drawTotal = 0;
    this.drawCount = 0;
    this.goldCount = 0;
    this.upGoldCount = 0;
    this.guaranteed = false;
  }

  draw(n) {
    let p, drawCount;
    for (let i = 0; i < n; i++) {
      ++this.drawTotal;
      drawCount = ++this.drawCount;
      if (drawCount <= 70)
        p = 0.008;
      else {
        p = (drawCount - 70) * 0.1 + 0.008;
        //p = p > 1 ? 1 : p;
      }
      if (Math.random() < p) {
        this.drawCount = 0;
        ++this.goldCount;
        if (this.guaranteed || Math.random() < 0.5) {
          this.guaranteed = false;
          ++this.upGoldCount;
        } else this.guaranteed = true;
      }
    }
    return {
      "drawTotal": this.drawTotal,
      "drawCount": this.drawCount,
      "GoldCount": this.goldCount,
      "GoldRate": this.goldCount / this.drawTotal,
      "UpGoldCount": this.upGoldCount,
      "UpGoldRate": this.upGoldCount / this.drawTotal
    };
  }
}

new DrawMachine().draw(160);
