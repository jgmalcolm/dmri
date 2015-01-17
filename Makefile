MATLAB=/projects/lmi/software/Matlab2008b64bit/bin/matlab
S = sleep $(shell bash -c "expr $$RANDOM % 60")
M = nice -10 $(MATLAB) -nojvm -nosplash -r

dt% :
	$(S)
	$(M) "run('DT', 'div',$*, 'ndiv',10);quit"

a% :
	$(S)
	$(M) "run('1T', 'div',$*, 'ndiv',10);quit"

lm% :
	$(S)
	$(M) "run_resume('LM', $*, 10);quit"

b% :
	$(S)
	$(M) "run('2T', 'div',$*, 'ndiv',7);quit"

c% :
	$(S)
	$(M) "run('3T', 'div',$*, 'ndiv',10);quit"







brain2_% :
	$(S)
	$(M) "run_pbc('brain2', $*,10);quit"


%_1T_ :
	$(S)
	$(M) "run_fb_resume($*,'1T',1,1);quit"
%_2T_ :
	$(S)
	$(M) "run_fb_resume($*,'2T',1,1);quit"
%_1Ta_ :
	$(S)
	$(M) "run_fb_resume($*,'1T',1,2);quit"
%_1Tb_ :
	$(S)
	$(M) "run_fb_resume($*,'1T',1,2);quit"
%_1Ta :
	$(S)
	$(M) "run_fb($*,'1T',1,2);quit"
%_1Tb :
	$(S)
	$(M) "run_fb($*,'1T',2,2);quit"
%_2Ta :
	$(S)
	$(M) "run_fb($*,'2T',1,2);quit"
%_2Tb :
	$(S)
	$(M) "run_fb($*,'2T',2,2);quit"
%_2Ta_ :
	$(S)
	$(M) "run_fb_resume($*,'2T',1,2);quit"
%_2Tb_ :
	$(S)
	$(M) "run_fb_resume($*,'2T',2,2);quit"


/tmp/%.nrrd : /projects/schiz/3Tdata/case%/diff/*-dwi-filt-[Ee]d.nhdr
	@#sleep $(shell bash -c "expr $$RANDOM % 300")
	tend estim -fixneg -B kvp -knownB0 true -i $^ -o $@
