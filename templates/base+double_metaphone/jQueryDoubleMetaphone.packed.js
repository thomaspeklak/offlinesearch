(function($){String.prototype.doubleMetaphone=function(){var a=new Array,secondary=new Array,current=0;var b=this.toUpperCase()+'     ',length=this.length,last=length-1;if(/^GN|KN|PN|WR|PS$/.test(b.substr(0,2)))current+=1;if('X'==b.substr(0,1)){a.push('S');secondary.push('S');current+=1}var c=new Array;while((a.length<4||secondary.length<4)&&current<=length){c=double_metaphone_lookup(b,current,length,last);if(c[0])a.push(c[0]);if(c[1])secondary.push(c[1]);current+=c[2]}a=a.join('').substr(0,4);secondary=secondary.join('').substr(0,4);return[a,(a==secondary)?null:secondary]};String.prototype.slavo_germanic=function(){return/W|K|CZ|WITZ/.test(this)};String.prototype.vowel=function(){return/^[AEIOUY]$/.test(this)};var A='A',B='B',C='C',D='D',E='E',F='F',G='G',H='H',I='I',J='J',K='K',L='L',M='M',N='N',O='O',P='P',Q='Q',R='R',S='S',T='T',U='U',V='V',W='W',X='X',Y='Y',Z='Z';function double_metaphone_lookup(a,b,c,d){var e=a.charAt(b);switch(true){case e.vowel():return(b)?[null,null,1]:[A,A,1];case e==B:return[P,P,(B==a.charAt(b+1))?2:1];case e=='Ç':return[S,S,1];case e==C:if(b>1&&!a.charAt(b-2).vowel()&&'ACH'==a.substr(b-1,3)&&a.charAt(b+2)!=I&&(a.charAt(b+2)!=E||/^(B|M)ACHER$/.test(a.substr(b-2,6))))return[K,K,2];else if(!b&&'CAESAR'==a.substr(b,6))return[S,S,2];else if('CHIA'==a.substr(b,4))return[K,K,2];else if('CH'==a.substr(b,2)){if(b&&'CHAE'==a.substr(b,4))return[K,X,2];else if(!b&&(['HARAC','HARIS'].in_array(a.substr(b+1,5))||['HOR','HYM','HIA','HEM'].in_array(a.substr(b+1,3)))&&a.substr(0,5)!='CHORE')return[K,K,2];else if(['VON','VAN'].in_array(a.substr(0,4))||'SCH'==a.substr(0,3)||['ORCHES','ARCHIT','ORCHID'].in_array(a.substr(b-2,6))||/^T|S$/.test(a.charAt(b+2))||((!b||/^[AOUE]$/.test(a.charAt(b-1)))&&/^[LRNMBHFVW ]$/.test(a.charAt(b+2))))return[K,K,2];else if(b)return[('MC'==a.substr(0,2))?K:X,K,2];else return[X,X,2]}else if(Z==a.charAt(b+1)&&'WI'!=a.substr(b-2,2))return[S,X,2];else if('CIA'==a.substr(b+1,3))return[X,X,3];else if(C==a.charAt(b+1)&&1!=b&&M!=a.charAt(0)){if(/^[IEH]$/.test(a.charAt(b+2))&&'HU'!=a.substr(b+2,2)){if((1==b&&A==a.charAt(b-1))||/^UCCE(E|S)$/.test(a.substr(b-1,5)))return['KS','KS',3];else return[X,X,3]}else return[K,K,2]}else if(/^[KGQ]$/.test(a.charAt(b+1)))return[K,K,2];else if(/^[IEY]$/.test(a.charAt(b+1)))return[S,(/^I(O|E|A)$/.test(a.substr(b+1,2))?X:S),2];else{if(/^ (C|Q|G)$/.test(a.substr(b+1,2)))return[K,K,3];else return[K,K,(/^[CKQ]$/.test(a.charAt(b+1))&&!(['CE','CI'].in_array(a.substr(b+1,2))))?2:1]}case e==D:if(a.charAt(b+1)==G){if(/^[IEY]$/.test(a.charAt(b+2)))return[J,J,3];else return['TK','TK',2]}else return[T,T,(/^[DT]$/.test(a.charAt(b+1)))?2:1];case e==F:return[F,F,(F==a.charAt(b+1))?2:1];case e==G:if(H==a.charAt(b+1)){if(b&&!a.charAt(b-1).vowel())return[K,K,2];else if(!b){if(I==a.charAt(b+2))return[J,J,2];else return[K,K,2]}else if((b>1&&/^[BHD]$/.test(a.charAt(b-2)))||(b>2&&/^[BHD]$/.test(a.charAt(b-3)))||(b>3&&/^B|H$/.test(a.charAt(b-4))))return[null,null,2];else{if(b>2&&U==a.charAt(b-1)&&/^[CGLRT]$/.test(a.charAt(b-3)))return[F,F,2];else{if(b&&I!=a.charAt(b-1))return[K,K,2];else return[null,null,2]}}}else if(N==a.charAt(b+1)){if(1==b&&a.charAt(0).vowel()&&!a.slavo_germanic())return['KN',N,2];else{if('EY'!=a.substr(b+2,2)&&Y!=a.charAt(b+1)&&!a.slavo_germanic())return[N,'KN',2];else return['KN',N,2]}}else if('LI'==a.substr(b+1,2))return['KL',L,2];else if(!b&&(Y==a.charAt(b+1)||/^(E(S|P|B|L|Y|I|R)|I(B|L|N|E))$/.test(a.substr(b+1,2))))return[K,J,2];else if(('ER'==a.substr(b+1,2)||Y==a.charAt(b+1))&&!/^(D|R|M)ANGER$/.test(a.substr(0,6))&&!/^E|I$/.test(a.charAt(b-1))&&!/^(R|O)GY$/.test(a.substr(b-1,3)))return[K,J,2];else if(/^[EIY]$/.test(a.charAt(b+1))||/^(A|O)GGI$/.test(a.substr(b-1,4))){if(/^V(A|O)N $/.test(a.substr(0,4))||'SCH'==a.substr(0,3)||'ET'==a.substr(b+1,2))return[K,K,2];else{if('IER '==a.substr(b+1,4))return[J,J,2];else return[J,K,2]}}else if(G==a.charAt(b+1))return[K,K,2];else return[K,K,1];case e==H:if(!b||a.charAt(b-1).vowel()&&a.charAt(b+1).vowel())return[H,H,2];else return[null,null,1];case e==J:if('OSE'==a.substr(b+1,3)||'SAN '==a.substr(0,4)){if((!b&&' '==a.charAt(b+4))||'SAN '==a.substr(0,4))return[H,H,1];else return[J,H,1]}else{var f=(J==a.charAt(b+1))?2:1;if(!b&&'OSE'!=a.substr(b+1,3))return[J,A,f];else{if(a.charAt(b-1).vowel()&&!a.slavo_germanic()&&/^A|O$/.test(a.charAt(b+1)))return[J,H,f];else{if(d==b)return[J,null,f];else{if(!/^[LTKSNMBZ]$/.test(a.charAt(b+1))&&!/^[SKL]$/.test(a.charAt(b-1)))return[J,J,f];else return[null,null,f]}}}}case e==K:return[K,K,(K==a.charAt(b+1))?2:1];case e==L:if(L==a.charAt(b+1)){if(((c-3)==b&&/^(ILL(O|A)|ALLE)$/.test(a.substr(b-1,4)))||(/^(A|O)S$/.test(a.substr(d-1,2))||/^A|O$/.test(a.charAt(d))&&'ALLE'==a.substr(b-1,4)))return[L,null,2];else return[L,L,2]}else return[L,L,1];case e==M:if(('UMB'==a.substr(b-1,3)&&(d-1==b||'ER'==a.substr(b+2,2)))||M==a.charAt(b+1))return[M,M,2];else return[M,M,1];case e==N:return[N,N,(N==a.charAt(b+1))?2:1];case e=='Ñ':return[N,N,1];case e==P:if(H==a.charAt(b+1))return[F,F,2];else return[P,P,(/^P|B$/.test(a.charAt(b+1)))?2:1];case e==Q:return[K,K,(Q==a.charAt(+1))?2:1];case e==R:var f=(R==a.charAt(b+1))?2:1;if(d==b&&!a.slavo_germanic()&&'IE'==a.substr(b-2,2)&&!/^M(E|A)$/.test(a.substr(b-4,2)))return[null,R,f];else return[R,R,f];case e==S:if(/^(I|Y)SL$/.test(a.substr(b-1,3)))return[null,null,1];else if(H==a.charAt(b+1)){if(/^H(EIM|OEK|OLM|OLZ)$/.test(a.substr(b+1,4)))return[S,S,2];else return[X,X,2]}else if(/^I(O|A)$/.test(a.substr(b+1,2)))return[S,(a.slavo_germanic())?S:X,3];else if((!b&&/^[MNLW]$/.test(a.charAt(+1)))||Z==a.charAt(b+1))return[S,X,(Z==a.charAt(b+1))?2:1];else if(C==a.charAt(b+1)){if(H==a.charAt(b+2)){if(/^OO|ER|EN|UY|ED|EM$/.test(a.substr(b+3,2)))return[(/^E(R|N)$/.test(a.substr(b+3,2)))?X:'SK','SK',3];else return[X,((!b&&!a.charAt(3).vowel())&&(W!=a.charAt(b+3)))?S:X,3]}else if(/^[IEY]$/.test(a.charAt(b+2)))return[S,S,3];else return['SK','SK',3]}else return[(d==b&&/^(A|O)I$/.test(a.substr(b-2,2)))?null:S,S,(/^S|Z$/.test(a.charAt(b+1)))?2:1];case e==T:if('ION'==a.substr(b+1,3)||/^IA|CH$/.test(a.substr(b+1,2)))return[X,X,3];else if(H==a.charAt(b+1)||'TH'==a.substr(b+1,2)){if(/^(O|A)M$/.test(a.substr(b+2,2))||/^V(A|O)N $/.test(a.substr(0,4))||'SCH'==a.substr(0,3))return[T,T,2];else return['0',T,2]}else return[T,T,(/^T|D$/.test(a.charAt(b+1)))?2:1];case e==V:return[F,F,(V==a.charAt(b+1))?2:1];case e==W:if(R==a.charAt(b+1))return[R,R,2];var g='';var h='';if(!b&&a.charAt(b+1).vowel()||H==a.charAt(b+1)){g=A;h=(a.charAt(b+1).vowel())?F:A}if(d==b&&a.charAt(b-1).vowel()||'SCH'==a.substr(0,3)||/^EWSKI|EWSKY|OWSKI|OWSKY$/.test(a.substr(b-1,5)))return[g,h+F,1];else if(/^I(C|T)Z$/.test(a.substr(b+1,3)))return[g+'TS',h+'FX',4];else return[g,h,1];case e==X:var f=(/^C|X$/.test(a.charAt(b+1)))?2:1;if(d==b&&(/^(I|E)AU$/.test(a.substr(b-3,3))||/^(A|O)U$/.test(a.substr(b-2,2))))return[null,null,f];else return['KS','KS',f];case e==Z:if(H==a.charAt(b+1))return[J,J,2];else{var f=(Z==a.charAt(b+1))?2:1;if(/^Z(O|I|A)$/.test(a.substr(b+1,2))||(a.slavo_germanic()&&(b>0&&T!=a.charAt(b-1))))return[S,'TS',f];else return[S,S,f]}}return[null,null,1]};Array.prototype.in_array=function(a){for(var i=0,l=this.length;i<l;i++){if(this[i]==a)return true}return false}})(jQuery);