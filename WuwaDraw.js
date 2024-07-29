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
      if (drawCount < 70)
        p = 0.008;
      else if (drawCount < 80)
        p = (drawCount - 69) * 0.08 + 0.008;
      else
        p = 1;
      if (Math.random() < p) {
        this.drawCount = 0;
        ++this.goldCount;
        if (this.guaranteed || Math.random() < 0.5) {
          this.guaranteed = false;
          ++this.upGoldCount;
        } else this.guaranteed = true;
      }
    }
    const realDrawTotal = (this.drawTotal - this.drawCount);
    return {
      "DrawTotal": this.drawTotal,
      "DrawCount": this.drawCount,
      "GoldCount": this.goldCount,
      "DrawCountPerGold": realDrawTotal / this.goldCount,
      "UpGoldCount": this.upGoldCount,
      "DrawCountPerUpGold": realDrawTotal / this.upGoldCount
    };
  }
}


new DrawMachine().draw(50000000);
