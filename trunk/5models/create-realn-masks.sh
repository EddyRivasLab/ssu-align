../../easel/miniapps/esl-alimanip -k -o archaea-0p1.p.k.stk archaea-0p1.p.stk 
../../easel/miniapps/esl-alimanip -o trash.stk --omask archaea-0p1-seed-realn.mask --p-rf --pfract 0.95 --pthresh 0.95 archaea-0p1.p.k.stk 

../../easel/miniapps/esl-alimanip -k -o bacteria-0p1.p.k.stk bacteria-0p1.p.stk 
../../easel/miniapps/esl-alimanip -o trash.stk --omask bacteria-0p1-seed-realn.mask --p-rf --pfract 0.95 --pthresh 0.95 bacteria-0p1.p.k.stk 

../../easel/miniapps/esl-alimanip -k -o chloroplast-0p1.p.k.stk chloroplast-0p1.p.stk 
../../easel/miniapps/esl-alimanip -o trash.stk --omask chloroplast-0p1-seed-realn.mask --p-rf --pfract 0.95 --pthresh 0.95 chloroplast-0p1.p.k.stk 

../../easel/miniapps/esl-alimanip -k -o eukarya-0p1.p.k.stk eukarya-0p1.p.stk 
../../easel/miniapps/esl-alimanip -o trash.stk --omask eukarya-0p1-seed-realn.mask --p-rf --pfract 0.95 --pthresh 0.95 eukarya-0p1.p.k.stk 

../../easel/miniapps/esl-alimanip -k -o metamito-0p1.p.k.stk metamito-0p1.p.stk 
../../easel/miniapps/esl-alimanip -o trash.stk --omask metamito-0p1-seed-realn.mask --p-rf --pfract 0.95 --pthresh 0.95 metamito-0p1.p.k.stk 
