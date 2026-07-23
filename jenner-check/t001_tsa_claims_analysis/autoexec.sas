/* cap input rows for the captured run */
options obs=100;

/* The upstream script assigned this library to a SAS OnDemand home path
   (/home/u61875322/...). Point it at the bundle's working directory so the
   author's cleaning + analysis steps run unchanged against the sample below. */
libname tsa ".";
