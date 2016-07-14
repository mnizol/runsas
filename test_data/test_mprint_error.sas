options mprint;

%macro test;
	data _null_;
		put "ERROR: macro error.";
	run;
%mend test;
%test;