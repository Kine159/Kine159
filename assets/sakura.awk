# Sakura banner generator.  usage: awk -v theme=light -v seed=11 -f sakura.awk
function rr(a,b) { return a + rand()*(b-a) }
function ri(a,b) { return int(a + rand()*(b-a+1)) }
function fx(v)   { return sprintf("%.1f", v) }
function f0(v)   { return sprintf("%d", int(v+0.5)) }

function seg(x1,y1,cx,cy,x2,y2,w) {
  nseg++
  sx1[nseg]=x1; sy1[nseg]=y1; scx[nseg]=cx; scy[nseg]=cy; sx2[nseg]=x2; sy2[nseg]=y2; sw[nseg]=w
}
function site(x,y) { nsite++; qx[nsite]=x; qy[nsite]=y }

function branch(x,y,ang,len,w,depth,    x2,y2,mx,my,curl,cx,cy,i,n,na,nl,nw,t) {
  x2 = x + cos(ang)*len
  y2 = y + sin(ang)*len
  # keep the crown inside the frame: flatten rather than escape the top edge
  if (y2 < 30) {
    t = 0.6
    ang = ang*(1-t) + (cos(ang) < 0 ? 3.1416 : 0)*t
    len = len*0.72; x2 = x + cos(ang)*len; y2 = y + sin(ang)*len
  }
  # and turn back in before running off the right edge
  if (x2 > 1190) {
    t = 0.5
    ang = ang*(1-t) + (-1.5708)*t
    len = len*0.72; x2 = x + cos(ang)*len; y2 = y + sin(ang)*len
  }
  mx = (x+x2)/2; my = (y+y2)/2
  curl = rr(-0.34,0.34)*len
  cx = mx + cos(ang+1.5708)*curl
  cy = my + sin(ang+1.5708)*curl
  seg(x,y,cx,cy,x2,y2,w)
  if (w < 3.2) site(x2,y2)
  if (depth<=0) { site(x2,y2); return }
  n = (rand()<0.24) ? 3 : 2
  for (i=1;i<=n;i++) {
    if (rand()<0.08 && depth<4) continue
    na = ang + rr(-0.66,0.66)
    if (depth<=2) { t=rr(0.12,0.38); na = na*(1-t) + 1.5708*t }   # tips droop
    else          { t=rr(0.02,0.10); na = na*(1-t) - 1.5708*t }   # limbs reach up
    nl = len*rr(0.72,0.86)
    nw = w*0.68; if (nw<0.8) nw=0.8
    branch(x2,y2,na,nl,nw,depth-1)
  }
}

BEGIN {
  W=1200; H=340
  if (seed=="") seed=11
  dark = (theme=="dark")

  if (dark) {
    sky1="#140e26"; sky2="#221934"; sky3="#31203d"
    orbFill="#ffeccf"; orbGlow="#ffd9a8"; orbOp="0.18"; orbA="0.95"
    hillFar="#201933"; hillNear="#181227"; ground="#130e1f"
    bark1="#6b4d5c"; bark2="#4a3644"
    b0="#ffe4ee"; b1="#f5a8c8"; b2="#dd85ac"; bcore="#ffe9a8"
    mass="#b5628c"; massOp="0.20"
    petalC="#f5a8c8"; nameC="#fdf3f8"; subC="#c9a8bd"; ruleC="#7d5d74"
    mistC="#3a2a48"; mistOp="0.32"
  } else {
    sky1="#fff9fc"; sky2="#ffedf4"; sky3="#ffe1ec"
    orbFill="#fff6de"; orbGlow="#ffe6b5"; orbOp="0.50"; orbA="0.80"
    hillFar="#f2e3ec"; hillNear="#e9d3e0"; ground="#f5e1e9"
    bark1="#8a6270"; bark2="#63434f"
    b0="#fff4f9"; b1="#ffc6dc"; b2="#ff9ec3"; bcore="#ffd98a"
    mass="#ffb8d3"; massOp="0.26"
    petalC="#ffb0ce"; nameC="#3d2b36"; subC="#8d6a7b"; ruleC="#dcaec3"
    mistC="#fff4f9"; mistOp="0.7"
  }

  printf "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 %d %d\" width=\"%d\" height=\"%d\" role=\"img\">\n", W,H,W,H
  print "<title>Sakura tree banner</title>"
  print "<defs>"
  printf "<linearGradient id=\"sky\" x1=\"0\" y1=\"0\" x2=\"0.25\" y2=\"1\"><stop offset=\"0\" stop-color=\"%s\"/><stop offset=\"0.55\" stop-color=\"%s\"/><stop offset=\"1\" stop-color=\"%s\"/></linearGradient>\n", sky1,sky2,sky3
  printf "<radialGradient id=\"orb\"><stop offset=\"0\" stop-color=\"%s\" stop-opacity=\"%s\"/><stop offset=\"1\" stop-color=\"%s\" stop-opacity=\"0\"/></radialGradient>\n", orbGlow,orbOp,orbGlow
  print "<filter id=\"soft\" x=\"-70%\" y=\"-70%\" width=\"240%\" height=\"240%\"><feGaussianBlur stdDeviation=\"24\"/></filter>"
  print "<clipPath id=\"frame\"><rect x=\"0\" y=\"0\" width=\"1200\" height=\"340\" rx=\"14\"/></clipPath>"
  for (v=0; v<3; v++) {
    c = (v==0)?b0:((v==1)?b1:b2)
    printf "<g id=\"f%d\">", v
    for (p=0;p<5;p++) printf "<ellipse cx=\"0\" cy=\"-3.2\" rx=\"2.4\" ry=\"3.5\" fill=\"%s\" transform=\"rotate(%d)\"/>", c, p*72
    printf "<circle r=\"1.1\" fill=\"%s\"/></g>\n", bcore
  }
  printf "<path id=\"pt\" d=\"M0,-4 C3.4,-3.4 4.2,0.6 0,5 C-4.2,0.6 -3.4,-3.4 0,-4 Z\" fill=\"%s\"/>\n", petalC
  print "</defs>"
  print "<g clip-path=\"url(#frame)\">"
  print "<rect width=\"1200\" height=\"340\" fill=\"url(#sky)\"/>"

  srand(seed)
  if (dark) {
    print "<g>"
    for (i=0;i<80;i++) {
      sxx=rr(10,1190); syy=rr(8,250); sr=rr(0.5,1.5); so=rr(0.25,0.9); sd=rr(2.5,6)
      printf "<circle cx=\"%s\" cy=\"%s\" r=\"%s\" fill=\"#fff6e8\" opacity=\"%s\">", fx(sxx),fx(syy),fx(sr),fx(so)
      printf "<animate attributeName=\"opacity\" values=\"%s;%s;%s\" dur=\"%ss\" begin=\"-%ss\" repeatCount=\"indefinite\"/></circle>\n", fx(so),fx(so*0.25),fx(so), fx(sd), fx(rr(0,sd))
    }
    print "</g>"
  }

  ox=196; oy=74
  printf "<circle cx=\"%d\" cy=\"%d\" r=\"128\" fill=\"url(#orb)\"/>\n", ox,oy
  printf "<circle cx=\"%d\" cy=\"%d\" r=\"33\" fill=\"%s\" opacity=\"%s\"/>\n", ox,oy,orbFill,orbA
  if (dark) {
    printf "<circle cx=\"%d\" cy=\"%d\" r=\"5\" fill=\"#e4cbab\" opacity=\"0.45\"/>\n", ox-11, oy-7
    printf "<circle cx=\"%d\" cy=\"%d\" r=\"3.2\" fill=\"#e4cbab\" opacity=\"0.38\"/>\n", ox+8, oy+6
    printf "<circle cx=\"%d\" cy=\"%d\" r=\"2.2\" fill=\"#e4cbab\" opacity=\"0.34\"/>\n", ox-3, oy+13
  }

  printf "<path d=\"M-20,292 Q 150,248 330,282 Q 520,318 700,276 Q 900,232 1220,288 L1220,360 L-20,360 Z\" fill=\"%s\" opacity=\"0.85\"/>\n", hillFar
  printf "<path d=\"M-20,318 Q 220,286 430,312 Q 650,340 880,304 Q 1060,276 1220,312 L1220,360 L-20,360 Z\" fill=\"%s\"/>\n", hillNear
  printf "<rect x=\"-20\" y=\"324\" width=\"1240\" height=\"40\" fill=\"%s\"/>\n", ground
  printf "<ellipse cx=\"620\" cy=\"302\" rx=\"560\" ry=\"24\" fill=\"%s\" opacity=\"%s\" filter=\"url(#soft)\"/>\n", mistC, mistOp

  # ---------- grow the tree ----------
  srand(seed+1)
  nseg=0; nsite=0
  # trunk: a short tapering stack of segments, leaning left
  bx0=1012; by0=340; ang=-1.5708-0.17; w=30; len=38
  for (i=0;i<4;i++) {
    x2 = bx0 + cos(ang)*len; y2 = by0 + sin(ang)*len
    mx=(bx0+x2)/2; my=(by0+y2)/2
    curl = rr(-0.16,0.10)*len
    seg(bx0,by0, mx+cos(ang+1.5708)*curl, my+sin(ang+1.5708)*curl, x2,y2, w)
    trkx[i]=x2; trky[i]=y2
    bx0=x2; by0=y2
    w*=0.87; len*=1.02; ang += rr(-0.08,0.05)
  }
  # major limbs — one long reach to the left frames the name
  branch(trkx[3], trky[3], -2.70, 102, 12.0, 5)
  branch(trkx[3], trky[3], -1.80,  92, 13.0, 5)
  branch(trkx[3], trky[3], -0.70,  86, 11.5, 5)
  branch(trkx[2], trky[2], -2.42,  84, 10.0, 5)
  branch(trkx[2], trky[2], -0.95,  78,  9.0, 5)
  branch(trkx[1], trky[1], -2.58,  60,  6.5, 4)

  # canopy mass — soft, low-opacity bloom behind the flowers
  print "<g filter=\"url(#soft)\">"
  for (i=1;i<=nsite;i+=9) {
    printf "<ellipse cx=\"%s\" cy=\"%s\" rx=\"%s\" ry=\"%s\" fill=\"%s\" opacity=\"%s\"/>\n", f0(qx[i]+rr(-14,14)), f0(qy[i]+rr(-12,12)), f0(rr(30,52)), f0(rr(24,38)), mass, massOp
  }
  print "</g>"

  # branches
  print "<g fill=\"none\" stroke-linecap=\"round\">"
  for (i=1;i<=nseg;i++) {
    col = (sw[i]>6) ? bark2 : bark1
    printf "<path d=\"M%s,%s Q%s,%s %s,%s\" stroke=\"%s\" stroke-width=\"%s\"/>\n", fx(sx1[i]),fx(sy1[i]),fx(scx[i]),fx(scy[i]),fx(sx2[i]),fx(sy2[i]), col, fx(sw[i])
  }
  print "</g>"
  printf "<path d=\"M980,338 Q1006,306 1012,340 Q1020,304 1046,338 Z\" fill=\"%s\"/>\n", bark2

  # blossoms — density normalised so the file stays a sane size
  target=900
  prob = target/nsite
  print "<g>"
  nb=0
  for (i=1;i<=nsite;i++) {
    k = int(prob); if (rand() < prob-k) k++
    for (j=0;j<k;j++) {
      printf "<use href=\"#f%d\" transform=\"translate(%s,%s) scale(%s)\"/>\n", ri(0,2), f0(qx[i]+rr(-13,13)), f0(qy[i]+rr(-13,13)), sprintf("%.2f", rr(0.55,1.3))
      nb++
    }
  }
  print "</g>"

  # fallen petals
  print "<g opacity=\"0.8\">"
  for (i=0;i<28;i++) printf "<use href=\"#pt\" transform=\"translate(%s,%s) rotate(%d) scale(%s)\"/>\n", f0(rr(40,1180)), f0(rr(316,338)), ri(0,359), sprintf("%.2f", rr(0.5,0.9))
  print "</g>"

  # falling petals
  print "<g>"
  for (i=0;i<28;i++) {
    px=rr(90,1190); py=rr(-60,-6)
    dur=rr(9,19); bg=rr(0,dur); swy=rr(24,70); sc=rr(0.55,1.15)
    d1=px-swy*0.45; d2=px+swy*0.30; d3=px-swy*0.85; d4=px-swy*1.25
    printf "<g opacity=\"0\">"
    printf "<animateTransform attributeName=\"transform\" type=\"translate\" values=\"%s,%s; %s,%s; %s,%s; %s,%s; %s,%s\" keyTimes=\"0;0.28;0.55;0.8;1\" dur=\"%ss\" begin=\"-%ss\" repeatCount=\"indefinite\" calcMode=\"spline\" keySplines=\"0.4 0 0.6 1;0.4 0 0.6 1;0.4 0 0.6 1;0.4 0 0.6 1\"/>", f0(px),f0(py), f0(d1),f0(py+95), f0(d2),f0(py+190), f0(d3),f0(py+285), f0(d4),f0(py+374), fx(dur), fx(bg)
    printf "<animate attributeName=\"opacity\" values=\"0;0.95;0.95;0\" keyTimes=\"0;0.08;0.82;1\" dur=\"%ss\" begin=\"-%ss\" repeatCount=\"indefinite\"/>", fx(dur), fx(bg)
    printf "<g><animateTransform attributeName=\"transform\" type=\"rotate\" values=\"0;360\" dur=\"%ss\" repeatCount=\"indefinite\"/>", fx(rr(3,7))
    printf "<use href=\"#pt\" transform=\"scale(%s)\"/></g></g>\n", sprintf("%.2f", sc)
  }
  print "</g>"

  printf "<text x=\"92\" y=\"180\" font-family=\"Georgia, 'Palatino Linotype', 'Book Antiqua', serif\" font-size=\"46\" fill=\"%s\">Trung Kien Pham</text>\n", nameC
  printf "<rect x=\"95\" y=\"202\" width=\"58\" height=\"2\" rx=\"1\" fill=\"%s\"/>\n", ruleC
  printf "<text x=\"95\" y=\"230\" font-family=\"'Segoe UI', Helvetica, Arial, sans-serif\" font-size=\"13\" letter-spacing=\"2.8\" fill=\"%s\">ACCOUNTING &#183; UNIVERSITY OF HOUSTON</text>\n", subC
  print "</g>"
  print "</svg>"
  printf "sites=%d blossoms=%d segs=%d\n", nsite, nb, nseg > "/dev/stderr"
}
