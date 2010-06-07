for model in archaea bacteria eukarya; do
    #ssu-esl-ssdraw --indi ../$model-0p1.stk $model-0p1.ps $model-0p1-indi.ps; ps2pdf $model-0p1-indi.ps


    ssu-esl-ssdraw --no-foot --no-cnt --info ../$model-0p1.stk $model-0p1.ps $model-0p1-info.ps; ps2pdf $model-0p1-info.ps
    ssu-esl-ssdraw --no-foot --no-cnt --mutinfo ../$model-0p1.stk $model-0p1.ps $model-0p1-mutinfo.ps; ps2pdf $model-0p1-mutinfo.ps
    ssu-esl-ssdraw --no-foot --no-cnt --iavglen ../$model-0p1.stk $model-0p1.ps $model-0p1-iavglen.ps; ps2pdf $model-0p1-iavglen.ps
    ssu-esl-ssdraw --no-foot --no-cnt --ifreq ../$model-0p1.stk $model-0p1.ps $model-0p1-ifreq.ps; ps2pdf $model-0p1-ifreq.ps
    ssu-esl-ssdraw --no-foot --no-cnt --dall ../$model-0p1.stk $model-0p1.ps $model-0p1-dall.ps; ps2pdf $model-0p1-dall.ps
    ssu-esl-ssdraw --no-foot --no-cnt --dint ../$model-0p1.stk $model-0p1.ps $model-0p1-dint.ps; ps2pdf $model-0p1-dint.ps
    ssu-esl-ssdraw --no-foot --no-cnt --prob ../$model-0p1.p.stk $model-0p1.ps $model-0p1-prob.ps; ps2pdf $model-0p1-prob.ps

    ssu-esl-ssdraw --no-foot --info ../$model-0p1.stk $model-0p1.ps $model-0p1-info.cnt.ps; ps2pdf $model-0p1-info.cnt.ps
    ssu-esl-ssdraw --no-foot --mutinfo ../$model-0p1.stk $model-0p1.ps $model-0p1-mutinfo.cnt.ps; ps2pdf $model-0p1-mutinfo.cnt.ps
    ssu-esl-ssdraw --no-foot --iavglen ../$model-0p1.stk $model-0p1.ps $model-0p1-iavglen.cnt.ps; ps2pdf $model-0p1-iavglen.cnt.ps
    ssu-esl-ssdraw --no-foot --ifreq ../$model-0p1.stk $model-0p1.ps $model-0p1-ifreq.cnt.ps; ps2pdf $model-0p1-ifreq.cnt.ps
    ssu-esl-ssdraw --no-foot --dall ../$model-0p1.stk $model-0p1.ps $model-0p1-dall.cnt.ps; ps2pdf $model-0p1-dall.cnt.ps
    ssu-esl-ssdraw --no-foot --dint ../$model-0p1.stk $model-0p1.ps $model-0p1-dint.cnt.ps; ps2pdf $model-0p1-dint.cnt.ps

    ssu-esl-ssdraw --no-foot --prob ../$model-0p1.p.stk $model-0p1.ps $model-0p1-prob.cnt.ps; ps2pdf $model-0p1-prob.cnt.ps
    ssu-esl-ssdraw --no-foot --rf ../$model-0p1.p.stk $model-0p1.ps $model-0p1-rf.ps; ps2pdf $model-0p1-rf.ps

    ssu-esl-ssdraw --no-foot --no-cnt --mask ../masks/$model-0p1.mask --info ../$model-0p1.stk $model-0p1.ps $model-0p1-info-wmask.ps; ps2pdf $model-0p1-info-wmask.ps
    ssu-esl-ssdraw --no-foot --no-cnt --mask ../masks/$model-0p1.mask --mutinfo ../$model-0p1.stk $model-0p1.ps $model-0p1-mutinfo-wmask.ps; ps2pdf $model-0p1-mutinfo-wmask.ps
    ssu-esl-ssdraw --no-foot --no-cnt --mask ../masks/$model-0p1.mask --iavglen ../$model-0p1.stk $model-0p1.ps $model-0p1-iavglen-wmask.ps; ps2pdf $model-0p1-iavglen-wmask.ps
    ssu-esl-ssdraw --no-foot --no-cnt --mask ../masks/$model-0p1.mask --ifreq ../$model-0p1.stk $model-0p1.ps $model-0p1-ifreq-wmask.ps; ps2pdf $model-0p1-ifreq-wmask.ps
    ssu-esl-ssdraw --no-foot --no-cnt --mask ../masks/$model-0p1.mask --dall ../$model-0p1.stk $model-0p1.ps $model-0p1-dall-wmask.ps; ps2pdf $model-0p1-dall-wmask.ps
    ssu-esl-ssdraw --no-foot --no-cnt --mask ../masks/$model-0p1.mask --dint ../$model-0p1.stk $model-0p1.ps $model-0p1-dint-wmask.ps; ps2pdf $model-0p1-dint-wmask.ps
    ssu-esl-ssdraw --no-foot --no-cnt --mask ../masks/$model-0p1.mask --prob ../$model-0p1.p.stk $model-0p1.ps $model-0p1-prob-wmask.ps; ps2pdf $model-0p1-prob-wmask.ps

    ssu-esl-ssdraw --no-foot --mask-col --mask ../masks/$model-0p1.mask ../$model-0p1.stk $model-0p1.ps $model-0p1-mask.ps; ps2pdf $model-0p1-mask.ps
done
