#line 1 "Source\\os_core.c"














 










 






#line 1 ".\\Source\\ucos_ii.h"














 






 












 







 

#line 1 ".\\Config\\app_cfg.h"












 










 









 

#line 1 "D:\\Keil\\ARM\\ARMCC\\Bin\\..\\include\\stdarg.h"
 
 
 





 










#line 27 "D:\\Keil\\ARM\\ARMCC\\Bin\\..\\include\\stdarg.h"








 

 
 
#line 57 "D:\\Keil\\ARM\\ARMCC\\Bin\\..\\include\\stdarg.h"
    typedef struct __va_list { void *__ap; } va_list;

   






 


   










 


   















 




   

 


   




 



   





 







#line 138 "D:\\Keil\\ARM\\ARMCC\\Bin\\..\\include\\stdarg.h"



#line 147 "D:\\Keil\\ARM\\ARMCC\\Bin\\..\\include\\stdarg.h"

 

#line 37 ".\\Config\\app_cfg.h"
#line 1 "D:\\Keil\\ARM\\ARMCC\\Bin\\..\\include\\stdio.h"
 
 
 





 






 







 




  
 








#line 47 "D:\\Keil\\ARM\\ARMCC\\Bin\\..\\include\\stdio.h"


  



    typedef unsigned int size_t;    









 
 

 



    typedef struct __va_list __va_list;






   




 




typedef struct __fpos_t_struct {
    unsigned __int64 __pos;
    



 
    struct {
        unsigned int __state1, __state2;
    } __mbstate;
} fpos_t;
   


 


   

 

typedef struct __FILE FILE;
   






 

#line 136 "D:\\Keil\\ARM\\ARMCC\\Bin\\..\\include\\stdio.h"


extern FILE __stdin, __stdout, __stderr;
extern FILE *__aeabi_stdin, *__aeabi_stdout, *__aeabi_stderr;

#line 166 "D:\\Keil\\ARM\\ARMCC\\Bin\\..\\include\\stdio.h"
    

    

    





     



   


 


   


 

   



 

   


 




   


 





    


 






extern __declspec(__nothrow) int remove(const char *  ) __attribute__((__nonnull__(1)));
   





 
extern __declspec(__nothrow) int rename(const char *  , const char *  ) __attribute__((__nonnull__(1,2)));
   








 
extern __declspec(__nothrow) FILE *tmpfile(void);
   




 
extern __declspec(__nothrow) char *tmpnam(char *  );
   











 

extern __declspec(__nothrow) int fclose(FILE *  ) __attribute__((__nonnull__(1)));
   







 
extern __declspec(__nothrow) int fflush(FILE *  );
   







 
extern __declspec(__nothrow) FILE *fopen(const char * __restrict  ,
                           const char * __restrict  ) __attribute__((__nonnull__(1,2)));
   








































 
extern __declspec(__nothrow) FILE *freopen(const char * __restrict  ,
                    const char * __restrict  ,
                    FILE * __restrict  ) __attribute__((__nonnull__(2,3)));
   








 
extern __declspec(__nothrow) void setbuf(FILE * __restrict  ,
                    char * __restrict  ) __attribute__((__nonnull__(1)));
   




 
extern __declspec(__nothrow) int setvbuf(FILE * __restrict  ,
                   char * __restrict  ,
                   int  , size_t  ) __attribute__((__nonnull__(1)));
   















 
#pragma __printf_args
extern __declspec(__nothrow) int fprintf(FILE * __restrict  ,
                    const char * __restrict  , ...) __attribute__((__nonnull__(1,2)));
   


















 
#pragma __printf_args
extern __declspec(__nothrow) int _fprintf(FILE * __restrict  ,
                     const char * __restrict  , ...) __attribute__((__nonnull__(1,2)));
   



 
#pragma __printf_args
extern __declspec(__nothrow) int printf(const char * __restrict  , ...) __attribute__((__nonnull__(1)));
   




 
#pragma __printf_args
extern __declspec(__nothrow) int _printf(const char * __restrict  , ...) __attribute__((__nonnull__(1)));
   



 
#pragma __printf_args
extern __declspec(__nothrow) int sprintf(char * __restrict  , const char * __restrict  , ...) __attribute__((__nonnull__(1,2)));
   






 
#pragma __printf_args
extern __declspec(__nothrow) int _sprintf(char * __restrict  , const char * __restrict  , ...) __attribute__((__nonnull__(1,2)));
   



 

#pragma __printf_args
extern __declspec(__nothrow) int __ARM_snprintf(char * __restrict  , size_t  ,
                     const char * __restrict  , ...) __attribute__((__nonnull__(3)));


#pragma __printf_args
extern __declspec(__nothrow) int snprintf(char * __restrict  , size_t  ,
                     const char * __restrict  , ...) __attribute__((__nonnull__(3)));
   















 

#pragma __printf_args
extern __declspec(__nothrow) int _snprintf(char * __restrict  , size_t  ,
                      const char * __restrict  , ...) __attribute__((__nonnull__(3)));
   



 
#pragma __scanf_args
extern __declspec(__nothrow) int fscanf(FILE * __restrict  ,
                    const char * __restrict  , ...) __attribute__((__nonnull__(1,2)));
   






























 
#pragma __scanf_args
extern __declspec(__nothrow) int _fscanf(FILE * __restrict  ,
                     const char * __restrict  , ...) __attribute__((__nonnull__(1,2)));
   



 
#pragma __scanf_args
extern __declspec(__nothrow) int scanf(const char * __restrict  , ...) __attribute__((__nonnull__(1)));
   






 
#pragma __scanf_args
extern __declspec(__nothrow) int _scanf(const char * __restrict  , ...) __attribute__((__nonnull__(1)));
   



 
#pragma __scanf_args
extern __declspec(__nothrow) int sscanf(const char * __restrict  ,
                    const char * __restrict  , ...) __attribute__((__nonnull__(1,2)));
   








 
#pragma __scanf_args
extern __declspec(__nothrow) int _sscanf(const char * __restrict  ,
                     const char * __restrict  , ...) __attribute__((__nonnull__(1,2)));
   



 

 
extern __declspec(__nothrow) int vfscanf(FILE * __restrict  , const char * __restrict  , __va_list) __attribute__((__nonnull__(1,2)));
extern __declspec(__nothrow) int vscanf(const char * __restrict  , __va_list) __attribute__((__nonnull__(1)));
extern __declspec(__nothrow) int vsscanf(const char * __restrict  , const char * __restrict  , __va_list) __attribute__((__nonnull__(1,2)));

extern __declspec(__nothrow) int _vfscanf(FILE * __restrict  , const char * __restrict  , __va_list) __attribute__((__nonnull__(1,2)));
extern __declspec(__nothrow) int _vscanf(const char * __restrict  , __va_list) __attribute__((__nonnull__(1)));
extern __declspec(__nothrow) int _vsscanf(const char * __restrict  , const char * __restrict  , __va_list) __attribute__((__nonnull__(1,2)));
extern __declspec(__nothrow) int __ARM_vsscanf(const char * __restrict  , const char * __restrict  , __va_list) __attribute__((__nonnull__(1,2)));

extern __declspec(__nothrow) int vprintf(const char * __restrict  , __va_list  ) __attribute__((__nonnull__(1)));
   





 
extern __declspec(__nothrow) int _vprintf(const char * __restrict  , __va_list  ) __attribute__((__nonnull__(1)));
   



 
extern __declspec(__nothrow) int vfprintf(FILE * __restrict  ,
                    const char * __restrict  , __va_list  ) __attribute__((__nonnull__(1,2)));
   






 
extern __declspec(__nothrow) int vsprintf(char * __restrict  ,
                     const char * __restrict  , __va_list  ) __attribute__((__nonnull__(1,2)));
   






 
extern __declspec(__nothrow) int __ARM_vsnprintf(char * __restrict  , size_t  ,
                     const char * __restrict  , __va_list  ) __attribute__((__nonnull__(3)));

extern __declspec(__nothrow) int vsnprintf(char * __restrict  , size_t  ,
                     const char * __restrict  , __va_list  ) __attribute__((__nonnull__(3)));
   







 

extern __declspec(__nothrow) int _vsprintf(char * __restrict  ,
                      const char * __restrict  , __va_list  ) __attribute__((__nonnull__(1,2)));
   



 
extern __declspec(__nothrow) int _vfprintf(FILE * __restrict  ,
                     const char * __restrict  , __va_list  ) __attribute__((__nonnull__(1,2)));
   



 
extern __declspec(__nothrow) int _vsnprintf(char * __restrict  , size_t  ,
                      const char * __restrict  , __va_list  ) __attribute__((__nonnull__(3)));
   



 

#pragma __printf_args
extern __declspec(__nothrow) int asprintf(char **  , const char * __restrict  , ...) __attribute__((__nonnull__(2)));
extern __declspec(__nothrow) int vasprintf(char **  , const char * __restrict  , __va_list  ) __attribute__((__nonnull__(2)));

#pragma __printf_args
extern __declspec(__nothrow) int __ARM_asprintf(char **  , const char * __restrict  , ...) __attribute__((__nonnull__(2)));
extern __declspec(__nothrow) int __ARM_vasprintf(char **  , const char * __restrict  , __va_list  ) __attribute__((__nonnull__(2)));
   








 

extern __declspec(__nothrow) int fgetc(FILE *  ) __attribute__((__nonnull__(1)));
   







 
extern __declspec(__nothrow) char *fgets(char * __restrict  , int  ,
                    FILE * __restrict  ) __attribute__((__nonnull__(1,3)));
   










 
extern __declspec(__nothrow) int fputc(int  , FILE *  ) __attribute__((__nonnull__(2)));
   







 
extern __declspec(__nothrow) int fputs(const char * __restrict  , FILE * __restrict  ) __attribute__((__nonnull__(1,2)));
   




 
extern __declspec(__nothrow) int getc(FILE *  ) __attribute__((__nonnull__(1)));
   







 




    extern __declspec(__nothrow) int (getchar)(void);

   





 
extern __declspec(__nothrow) char *gets(char *  ) __attribute__((__nonnull__(1)));
   









 
extern __declspec(__nothrow) int putc(int  , FILE *  ) __attribute__((__nonnull__(2)));
   





 




    extern __declspec(__nothrow) int (putchar)(int  );

   



 
extern __declspec(__nothrow) int puts(const char *  ) __attribute__((__nonnull__(1)));
   





 
extern __declspec(__nothrow) int ungetc(int  , FILE *  ) __attribute__((__nonnull__(2)));
   






















 

extern __declspec(__nothrow) size_t fread(void * __restrict  ,
                    size_t  , size_t  , FILE * __restrict  ) __attribute__((__nonnull__(1,4)));
   











 

extern __declspec(__nothrow) size_t __fread_bytes_avail(void * __restrict  ,
                    size_t  , FILE * __restrict  ) __attribute__((__nonnull__(1,3)));
   











 

extern __declspec(__nothrow) size_t fwrite(const void * __restrict  ,
                    size_t  , size_t  , FILE * __restrict  ) __attribute__((__nonnull__(1,4)));
   







 

extern __declspec(__nothrow) int fgetpos(FILE * __restrict  , fpos_t * __restrict  ) __attribute__((__nonnull__(1,2)));
   








 
extern __declspec(__nothrow) int fseek(FILE *  , long int  , int  ) __attribute__((__nonnull__(1)));
   














 
extern __declspec(__nothrow) int fsetpos(FILE * __restrict  , const fpos_t * __restrict  ) __attribute__((__nonnull__(1,2)));
   










 
extern __declspec(__nothrow) long int ftell(FILE *  ) __attribute__((__nonnull__(1)));
   











 
extern __declspec(__nothrow) void rewind(FILE *  ) __attribute__((__nonnull__(1)));
   





 

extern __declspec(__nothrow) void clearerr(FILE *  ) __attribute__((__nonnull__(1)));
   




 

extern __declspec(__nothrow) int feof(FILE *  ) __attribute__((__nonnull__(1)));
   


 
extern __declspec(__nothrow) int ferror(FILE *  ) __attribute__((__nonnull__(1)));
   


 
extern __declspec(__nothrow) void perror(const char *  );
   









 

extern __declspec(__nothrow) int _fisatty(FILE *   ) __attribute__((__nonnull__(1)));
    
 

extern __declspec(__nothrow) void __use_no_semihosting_swi(void);
extern __declspec(__nothrow) void __use_no_semihosting(void);
    





 











#line 1021 "D:\\Keil\\ARM\\ARMCC\\Bin\\..\\include\\stdio.h"



 

#line 38 ".\\Config\\app_cfg.h"






 









 









 

















 










 
























 




#line 46 ".\\Source\\ucos_ii.h"
#line 1 ".\\Config\\os_cfg.h"














 










 





                                        










                                        















                                        





                                        
#line 78 ".\\Config\\os_cfg.h"


                                        
#line 88 ".\\Config\\os_cfg.h"


                                        
#line 98 ".\\Config\\os_cfg.h"


                                        





                                        






                                        
#line 123 ".\\Config\\os_cfg.h"


                                        
#line 132 ".\\Config\\os_cfg.h"


                                        






                                        







                                        






#line 47 ".\\Source\\ucos_ii.h"
#line 1 ".\\Port\\os_cpu.h"














 


















 


















 


































 











#line 107 ".\\Port\\os_cpu.h"

#line 115 ".\\Port\\os_cpu.h"







 

typedef unsigned char  BOOLEAN;
typedef unsigned char  INT8U;                     
typedef signed   char  INT8S;                     
typedef unsigned short INT16U;                    
typedef signed   short INT16S;                    
typedef unsigned int   INT32U;                    
typedef signed   int   INT32S;                    
typedef float          FP32;                      
typedef double         FP64;                      

typedef unsigned int   OS_STK;                    
typedef unsigned int   OS_CPU_SR;                 






















 




                                                  
                                                  

                                                  








 










 

extern  OS_STK   OS_CPU_ExceptStk[256u];
extern  OS_STK  *OS_CPU_ExceptStkBase;






 


OS_CPU_SR  OS_CPU_SR_Save         (OS_CPU_SR  new_basepri);
void       OS_CPU_SR_Restore      (OS_CPU_SR  cpu_sr);


void       OSCtxSw                (void);
void       OSIntCtxSw             (void);
void       OSStartHighRdy         (void);

                                                  
void       OS_CPU_SysTickInit     (INT32U     cnts);
void       OS_CPU_SysTickInitFreq (INT32U     cpu_freq);

void       OS_CPU_SysTickHandler  (void);
void       OS_CPU_PendSVHandler   (void);


void       OS_CPU_FP_Reg_Push     (OS_STK    *stkPtr);
void       OS_CPU_FP_Reg_Pop      (OS_STK    *stkPtr);






 










 

#line 48 ".\\Source\\ucos_ii.h"
#line 1 ".\\Source\\os_trace.h"














 















 




#line 37 ".\\Source\\os_trace.h"










 

#line 61 ".\\Source\\os_trace.h"

#line 71 ".\\Source\\os_trace.h"



















































































































































































































































































































































































































#line 49 ".\\Source\\ucos_ii.h"





 





























#line 91 ".\\Source\\ucos_ii.h"













 
#line 113 ".\\Source\\ucos_ii.h"







 








 
#line 136 ".\\Source\\ucos_ii.h"


                                             





 

























 











 









 









 









 










 












 









 


#line 258 ".\\Source\\ucos_ii.h"

#line 269 ".\\Source\\ucos_ii.h"














#line 297 ".\\Source\\ucos_ii.h"

#line 304 ".\\Source\\ucos_ii.h"

#line 315 ".\\Source\\ucos_ii.h"



#line 324 ".\\Source\\ucos_ii.h"



#line 341 ".\\Source\\ucos_ii.h"














 

#line 364 ".\\Source\\ucos_ii.h"





 


typedef  INT8U    OS_PRIO;





typedef struct os_event {
    INT8U    OSEventType;                    
    void    *OSEventPtr;                     
    INT16U   OSEventCnt;                     
    OS_PRIO  OSEventGrp;                     
    OS_PRIO  OSEventTbl[((63u) / 8u + 1u)];  


    INT8U   *OSEventName;

} OS_EVENT;







 








typedef  INT16U   OS_FLAGS;







typedef struct os_flag_grp {                 
    INT8U         OSFlagType;                
    void         *OSFlagWaitList;            
    OS_FLAGS      OSFlagFlags;               

    INT8U        *OSFlagName;

} OS_FLAG_GRP;



typedef struct os_flag_node {                
    void         *OSFlagNodeNext;            
    void         *OSFlagNodePrev;            
    void         *OSFlagNodeTCB;             
    void         *OSFlagNodeFlagGrp;         
    OS_FLAGS      OSFlagNodeFlags;           
    INT8U         OSFlagNodeWaitType;        
                                             
                                             
                                             
                                             
} OS_FLAG_NODE;







 


typedef struct os_mbox_data {
    void   *OSMsg;                           
    OS_PRIO OSEventTbl[((63u) / 8u + 1u)];   
    OS_PRIO OSEventGrp;                      
} OS_MBOX_DATA;






 


typedef struct os_mem {                      
    void   *OSMemAddr;                       
    void   *OSMemFreeList;                   
    INT32U  OSMemBlkSize;                    
    INT32U  OSMemNBlks;                      
    INT32U  OSMemNFree;                      

    INT8U  *OSMemName;                       

} OS_MEM;


typedef struct os_mem_data {
    void   *OSAddr;                          
    void   *OSFreeList;                      
    INT32U  OSBlkSize;                       
    INT32U  OSNBlks;                         
    INT32U  OSNFree;                         
    INT32U  OSNUsed;                         
} OS_MEM_DATA;







 


typedef struct os_mutex_data {
    OS_PRIO OSEventTbl[((63u) / 8u + 1u)];   
    OS_PRIO OSEventGrp;                      
    BOOLEAN OSValue;                         
    INT8U   OSOwnerPrio;                     
    INT8U   OSMutexPCP;                      
} OS_MUTEX_DATA;






 


typedef struct os_q {                        
    struct os_q   *OSQPtr;                   
    void         **OSQStart;                 
    void         **OSQEnd;                   
    void         **OSQIn;                    
    void         **OSQOut;                   
    INT16U         OSQSize;                  
    INT16U         OSQEntries;               
} OS_Q;


typedef struct os_q_data {
    void          *OSMsg;                    
    INT16U         OSNMsgs;                  
    INT16U         OSQSize;                  
    OS_PRIO        OSEventTbl[((63u) / 8u + 1u)];   
    OS_PRIO        OSEventGrp;               
} OS_Q_DATA;






 


typedef struct os_sem_data {
    INT16U  OSCnt;                           
    OS_PRIO OSEventTbl[((63u) / 8u + 1u)];   
    OS_PRIO OSEventGrp;                      
} OS_SEM_DATA;






 


typedef struct os_stk_data {
    INT32U  OSFree;                          
    INT32U  OSUsed;                          
} OS_STK_DATA;







 

typedef struct os_tcb {
    OS_STK          *OSTCBStkPtr;            


    void            *OSTCBExtPtr;            
    OS_STK          *OSTCBStkBottom;         
    INT32U           OSTCBStkSize;           
    INT16U           OSTCBOpt;               
    INT16U           OSTCBId;                


    struct os_tcb   *OSTCBNext;              
    struct os_tcb   *OSTCBPrev;              








    OS_EVENT        *OSTCBEventPtr;          



    OS_EVENT       **OSTCBEventMultiPtr;     
    OS_EVENT        *OSTCBEventMultiRdy;     



    void            *OSTCBMsg;               




    OS_FLAG_NODE    *OSTCBFlagNode;          

    OS_FLAGS         OSTCBFlagsRdy;          


    INT32U           OSTCBDly;               
    INT8U            OSTCBStat;              
    INT8U            OSTCBStatPend;          
    INT8U            OSTCBPrio;              

    INT8U            OSTCBX;                 
    INT8U            OSTCBY;                 
    OS_PRIO          OSTCBBitX;              
    OS_PRIO          OSTCBBitY;              


    INT8U            OSTCBDelReq;            



    INT32U           OSTCBCtxSwCtr;          
    INT32U           OSTCBCyclesTot;         
    INT32U           OSTCBCyclesStart;       
    OS_STK          *OSTCBStkBase;           
    INT32U           OSTCBStkUsed;           



    INT8U           *OSTCBTaskName;



    INT32U           OSTCBRegTbl[1u];

} OS_TCB;






 


typedef  void (*OS_TMR_CALLBACK)(void *ptmr, void *parg);



typedef  struct  os_tmr {
    INT8U            OSTmrType;              
    OS_TMR_CALLBACK  OSTmrCallback;          
    void            *OSTmrCallbackArg;       
    void            *OSTmrNext;              
    void            *OSTmrPrev;
    INT32U           OSTmrMatch;             
    INT32U           OSTmrDly;               
    INT32U           OSTmrPeriod;            

    INT8U           *OSTmrName;              

    INT8U            OSTmrOpt;               
    INT8U            OSTmrState;             
                                             
                                             
                                             
} OS_TMR;



typedef  struct  os_tmr_wheel {
    OS_TMR          *OSTmrFirst;             
    INT16U           OSTmrEntries;
} OS_TMR_WHEEL;







 

#line 684 ".\\Source\\ucos_ii.h"





 

  INT32U            OSCtxSwCtr;                


  OS_EVENT         *OSEventFreeList;           
  OS_EVENT          OSEventTbl[10u]; 



  OS_FLAG_GRP       OSFlagTbl[5u];   
  OS_FLAG_GRP      *OSFlagFreeList;            



  INT8U             OSCPUUsage;                
  INT32U            OSIdleCtrMax;              
  INT32U            OSIdleCtrRun;              
  BOOLEAN           OSStatRdy;                 
  OS_STK            OSTaskStatStk[128u];       


  INT8U             OSIntNesting;              

  INT8U             OSLockNesting;             

  INT8U             OSPrioCur;                 
  INT8U             OSPrioHighRdy;             

  OS_PRIO           OSRdyGrp;                         
  OS_PRIO           OSRdyTbl[((63u) / 8u + 1u)];        

  BOOLEAN           OSRunning;                        

  INT8U             OSTaskCtr;                        

  volatile  INT32U  OSIdleCtr;                                  





  OS_STK            OSTaskIdleStk[128u];       


  OS_TCB           *OSTCBCur;                         
  OS_TCB           *OSTCBFreeList;                    
  OS_TCB           *OSTCBHighRdy;                     
  OS_TCB           *OSTCBList;                        
  OS_TCB           *OSTCBPrioTbl[63u + 1u];     
  OS_TCB            OSTCBTbl[20u + 2u];    


  INT8U             OSTickStepState;           



  OS_MEM           *OSMemFreeList;             
  OS_MEM            OSMemTbl[5u]; 



  OS_Q             *OSQFreeList;               
  OS_Q              OSQTbl[4u];         



  INT8U             OSTaskRegNextAvailID;      



  volatile  INT32U  OSTime;                    



  INT16U            OSTmrFree;                 
  INT16U            OSTmrUsed;                 
  INT32U            OSTmrTime;                 

  OS_EVENT         *OSTmrSem;                  
  OS_EVENT         *OSTmrSemSignal;            

  OS_TMR            OSTmrTbl[16u];  
  OS_TMR           *OSTmrFreeList;             
  OS_STK            OSTmrTaskStk[128u];

  OS_TMR_WHEEL      OSTmrWheelTbl[7u];


extern  INT8U   const     OSUnMapTbl[256];           







 





 




INT8U         OSEventNameGet          (OS_EVENT        *pevent,
                                       INT8U          **pname,
                                       INT8U           *perr);

void          OSEventNameSet          (OS_EVENT        *pevent,
                                       INT8U           *pname,
                                       INT8U           *perr);



INT16U        OSEventPendMulti        (OS_EVENT       **pevents_pend,
                                       OS_EVENT       **pevents_rdy,
                                       void           **pmsgs_rdy,
                                       INT32U           timeout,
                                       INT8U           *perr);








 

#line 850 ".\\Source\\ucos_ii.h"






 




OS_FLAGS      OSFlagAccept            (OS_FLAG_GRP     *pgrp,
                                       OS_FLAGS         flags,
                                       INT8U            wait_type,
                                       INT8U           *perr);


OS_FLAG_GRP  *OSFlagCreate            (OS_FLAGS         flags,
                                       INT8U           *perr);


OS_FLAG_GRP  *OSFlagDel               (OS_FLAG_GRP     *pgrp,
                                       INT8U            opt,
                                       INT8U           *perr);



INT8U         OSFlagNameGet           (OS_FLAG_GRP     *pgrp,
                                       INT8U          **pname,
                                       INT8U           *perr);

void          OSFlagNameSet           (OS_FLAG_GRP     *pgrp,
                                       INT8U           *pname,
                                       INT8U           *perr);


OS_FLAGS      OSFlagPend              (OS_FLAG_GRP     *pgrp,
                                       OS_FLAGS         flags,
                                       INT8U            wait_type,
                                       INT32U           timeout,
                                       INT8U           *perr);

OS_FLAGS      OSFlagPendGetFlagsRdy   (void);
OS_FLAGS      OSFlagPost              (OS_FLAG_GRP     *pgrp,
                                       OS_FLAGS         flags,
                                       INT8U            opt,
                                       INT8U           *perr);


OS_FLAGS      OSFlagQuery             (OS_FLAG_GRP     *pgrp,
                                       INT8U           *perr);







 




void         *OSMboxAccept            (OS_EVENT        *pevent);


OS_EVENT     *OSMboxCreate            (void            *pmsg);


OS_EVENT     *OSMboxDel               (OS_EVENT        *pevent,
                                       INT8U            opt,
                                       INT8U           *perr);


void         *OSMboxPend              (OS_EVENT        *pevent,
                                       INT32U           timeout,
                                       INT8U           *perr);


INT8U         OSMboxPendAbort         (OS_EVENT        *pevent,
                                       INT8U            opt,
                                       INT8U           *perr);



INT8U         OSMboxPost              (OS_EVENT        *pevent,
                                       void            *pmsg);



INT8U         OSMboxPostOpt           (OS_EVENT        *pevent,
                                       void            *pmsg,
                                       INT8U            opt);



INT8U         OSMboxQuery             (OS_EVENT        *pevent,
                                       OS_MBOX_DATA    *p_mbox_data);







 



OS_MEM       *OSMemCreate             (void            *addr,
                                       INT32U           nblks,
                                       INT32U           blksize,
                                       INT8U           *perr);

void         *OSMemGet                (OS_MEM          *pmem,
                                       INT8U           *perr);

INT8U         OSMemNameGet            (OS_MEM          *pmem,
                                       INT8U          **pname,
                                       INT8U           *perr);

void          OSMemNameSet            (OS_MEM          *pmem,
                                       INT8U           *pname,
                                       INT8U           *perr);

INT8U         OSMemPut                (OS_MEM          *pmem,
                                       void            *pblk);


INT8U         OSMemQuery              (OS_MEM          *pmem,
                                       OS_MEM_DATA     *p_mem_data);








 




BOOLEAN       OSMutexAccept           (OS_EVENT        *pevent,
                                       INT8U           *perr);


OS_EVENT     *OSMutexCreate           (INT8U            prio,
                                       INT8U           *perr);


OS_EVENT     *OSMutexDel              (OS_EVENT        *pevent,
                                       INT8U            opt,
                                       INT8U           *perr);


void          OSMutexPend             (OS_EVENT        *pevent,
                                       INT32U           timeout,
                                       INT8U           *perr);

INT8U         OSMutexPost             (OS_EVENT        *pevent);


INT8U         OSMutexQuery            (OS_EVENT        *pevent,
                                       OS_MUTEX_DATA   *p_mutex_data);









 




void         *OSQAccept               (OS_EVENT        *pevent,
                                       INT8U           *perr);


OS_EVENT     *OSQCreate               (void           **start,
                                       INT16U           size);


OS_EVENT     *OSQDel                  (OS_EVENT        *pevent,
                                       INT8U            opt,
                                       INT8U           *perr);



INT8U         OSQFlush                (OS_EVENT        *pevent);


void         *OSQPend                 (OS_EVENT        *pevent,
                                       INT32U           timeout,
                                       INT8U           *perr);


INT8U         OSQPendAbort            (OS_EVENT        *pevent,
                                       INT8U            opt,
                                       INT8U           *perr);



INT8U         OSQPost                 (OS_EVENT        *pevent,
                                       void            *pmsg);



INT8U         OSQPostFront            (OS_EVENT        *pevent,
                                       void            *pmsg);



INT8U         OSQPostOpt              (OS_EVENT        *pevent,
                                       void            *pmsg,
                                       INT8U            opt);



INT8U         OSQQuery                (OS_EVENT        *pevent,
                                       OS_Q_DATA       *p_q_data);









 



INT16U        OSSemAccept             (OS_EVENT        *pevent);


OS_EVENT     *OSSemCreate             (INT16U           cnt);


OS_EVENT     *OSSemDel                (OS_EVENT        *pevent,
                                       INT8U            opt,
                                       INT8U           *perr);


void          OSSemPend               (OS_EVENT        *pevent,
                                       INT32U           timeout,
                                       INT8U           *perr);


INT8U         OSSemPendAbort          (OS_EVENT        *pevent,
                                       INT8U            opt,
                                       INT8U           *perr);


INT8U         OSSemPost               (OS_EVENT        *pevent);


INT8U         OSSemQuery              (OS_EVENT        *pevent,
                                       OS_SEM_DATA     *p_sem_data);



void          OSSemSet                (OS_EVENT        *pevent,
                                       INT16U           cnt,
                                       INT8U           *perr);









 

INT8U         OSTaskChangePrio        (INT8U            oldprio,
                                       INT8U            newprio);



INT8U         OSTaskCreate            (void           (*task)(void *p_arg),
                                       void            *p_arg,
                                       OS_STK          *ptos,
                                       INT8U            prio);



INT8U         OSTaskCreateExt         (void           (*task)(void *p_arg),
                                       void            *p_arg,
                                       OS_STK          *ptos,
                                       INT8U            prio,
                                       INT16U           id,
                                       OS_STK          *pbos,
                                       INT32U           stk_size,
                                       void            *pext,
                                       INT16U           opt);



INT8U         OSTaskDel               (INT8U            prio);
INT8U         OSTaskDelReq            (INT8U            prio);



INT8U         OSTaskNameGet           (INT8U            prio,
                                       INT8U          **pname,
                                       INT8U           *perr);

void          OSTaskNameSet           (INT8U            prio,
                                       INT8U           *pname,
                                       INT8U           *perr);



INT8U         OSTaskResume            (INT8U            prio);
INT8U         OSTaskSuspend           (INT8U            prio);



INT8U         OSTaskStkChk            (INT8U            prio,
                                       OS_STK_DATA     *p_stk_data);



INT8U         OSTaskQuery             (INT8U            prio,
                                       OS_TCB          *p_task_data);





INT32U        OSTaskRegGet            (INT8U            prio,
                                       INT8U            id,
                                       INT8U           *perr);

INT8U         OSTaskRegGetID          (INT8U           *perr);

void          OSTaskRegSet            (INT8U            prio,
                                       INT8U            id,
                                       INT32U           value,
                                       INT8U           *perr);







 

void          OSTimeDly               (INT32U           ticks);


INT8U         OSTimeDlyHMSM           (INT8U            hours,
                                       INT8U            minutes,
                                       INT8U            seconds,
                                       INT16U           ms);



INT8U         OSTimeDlyResume         (INT8U            prio);



INT32U        OSTimeGet               (void);
void          OSTimeSet               (INT32U           ticks);


void          OSTimeTick              (void);





 


OS_TMR      *OSTmrCreate              (INT32U           dly,
                                       INT32U           period,
                                       INT8U            opt,
                                       OS_TMR_CALLBACK  callback,
                                       void            *callback_arg,
                                       INT8U           *pname,
                                       INT8U           *perr);

BOOLEAN      OSTmrDel                 (OS_TMR          *ptmr,
                                       INT8U           *perr);


INT8U        OSTmrNameGet             (OS_TMR          *ptmr,
                                       INT8U          **pdest,
                                       INT8U           *perr);

INT32U       OSTmrRemainGet           (OS_TMR          *ptmr,
                                       INT8U           *perr);

INT8U        OSTmrStateGet            (OS_TMR          *ptmr,
                                       INT8U           *perr);

BOOLEAN      OSTmrStart               (OS_TMR          *ptmr,
                                       INT8U           *perr);

BOOLEAN      OSTmrStop                (OS_TMR          *ptmr,
                                       INT8U            opt,
                                       void            *callback_arg,
                                       INT8U           *perr);

INT8U        OSTmrSignal              (void);






 

void          OSInit                  (void);

void          OSIntEnter              (void);
void          OSIntExit               (void);






void          OSSchedLock             (void);
void          OSSchedUnlock           (void);


void          OSStart                 (void);

void          OSStatInit              (void);

INT16U        OSVersion               (void);







 


void          OS_Dummy                (void);



INT8U         OS_EventTaskRdy         (OS_EVENT        *pevent,
                                       void            *pmsg,
                                       INT8U            msk,
                                       INT8U            pend_stat);

void          OS_EventTaskWait        (OS_EVENT        *pevent);

void          OS_EventTaskRemove      (OS_TCB          *ptcb,
                                       OS_EVENT        *pevent);


void          OS_EventTaskWaitMulti   (OS_EVENT       **pevents_wait);

void          OS_EventTaskRemoveMulti (OS_TCB          *ptcb,
                                       OS_EVENT       **pevents_multi);


void          OS_EventWaitListInit    (OS_EVENT        *pevent);



void          OS_FlagInit             (void);
void          OS_FlagUnlink           (OS_FLAG_NODE    *pnode);


void          OS_MemClr               (INT8U           *pdest,
                                       INT16U           size);

void          OS_MemCopy              (INT8U           *pdest,
                                       INT8U           *psrc,
                                       INT16U           size);


void          OS_MemInit              (void);



void          OS_QInit                (void);


void          OS_Sched                (void);


INT8U         OS_StrLen               (INT8U           *psrc);


void          OS_TaskIdle             (void            *p_arg);

void          OS_TaskReturn           (void);


void          OS_TaskStat             (void            *p_arg);



void          OS_TaskStkClr           (OS_STK          *pbos,
                                       INT32U           size,
                                       INT16U           opt);



void          OS_TaskStatStkChk       (void);


INT8U         OS_TCBInit              (INT8U            prio,
                                       OS_STK          *ptos,
                                       OS_STK          *pbos,
                                       INT16U           id,
                                       INT32U           stk_size,
                                       void            *pext,
                                       INT16U           opt);


void          OSTmr_Init              (void);








 


void          OSDebugInit             (void);


void          OSInitHookBegin         (void);
void          OSInitHookEnd           (void);

void          OSTaskCreateHook        (OS_TCB          *ptcb);
void          OSTaskDelHook           (OS_TCB          *ptcb);

void          OSTaskIdleHook          (void);

void          OSTaskReturnHook        (OS_TCB          *ptcb);

void          OSTaskStatHook          (void);
OS_STK       *OSTaskStkInit           (void           (*task)(void *p_arg),
                                       void            *p_arg,
                                       OS_STK          *ptos,
                                       INT16U           opt);


void          OSTaskSwHook            (void);


void          OSTCBInitHook           (OS_TCB          *ptcb);


void          OSTimeTickHook          (void);








 


void          App_TaskCreateHook      (OS_TCB          *ptcb);
void          App_TaskDelHook         (OS_TCB          *ptcb);
void          App_TaskIdleHook        (void);

void          App_TaskReturnHook      (OS_TCB          *ptcb);

void          App_TaskStatHook        (void);


void          App_TaskSwHook          (void);


void          App_TCBInitHook         (OS_TCB          *ptcb);


void          App_TimeTickHook        (void);









 


















 





 

#line 1491 ".\\Source\\ucos_ii.h"






























 

#line 1529 ".\\Source\\ucos_ii.h"


























 

#line 1567 ".\\Source\\ucos_ii.h"














 

#line 1589 ".\\Source\\ucos_ii.h"














 

#line 1615 ".\\Source\\ucos_ii.h"






































 

#line 1661 ".\\Source\\ucos_ii.h"






















 

#line 1691 ".\\Source\\ucos_ii.h"



































#line 1733 ".\\Source\\ucos_ii.h"

















#line 1757 ".\\Source\\ucos_ii.h"





 





















 

#line 1793 ".\\Source\\ucos_ii.h"

#line 1800 ".\\Source\\ucos_ii.h"






#line 1812 ".\\Source\\ucos_ii.h"
























 


























#line 1870 ".\\Source\\ucos_ii.h"



































 

#line 1982 ".\\Source\\ucos_ii.h"





#line 36 "Source\\os_core.c"









 

INT8U  const  OSUnMapTbl[256] = {
    0u, 0u, 1u, 0u, 2u, 0u, 1u, 0u, 3u, 0u, 1u, 0u, 2u, 0u, 1u, 0u,  
    4u, 0u, 1u, 0u, 2u, 0u, 1u, 0u, 3u, 0u, 1u, 0u, 2u, 0u, 1u, 0u,  
    5u, 0u, 1u, 0u, 2u, 0u, 1u, 0u, 3u, 0u, 1u, 0u, 2u, 0u, 1u, 0u,  
    4u, 0u, 1u, 0u, 2u, 0u, 1u, 0u, 3u, 0u, 1u, 0u, 2u, 0u, 1u, 0u,  
    6u, 0u, 1u, 0u, 2u, 0u, 1u, 0u, 3u, 0u, 1u, 0u, 2u, 0u, 1u, 0u,  
    4u, 0u, 1u, 0u, 2u, 0u, 1u, 0u, 3u, 0u, 1u, 0u, 2u, 0u, 1u, 0u,  
    5u, 0u, 1u, 0u, 2u, 0u, 1u, 0u, 3u, 0u, 1u, 0u, 2u, 0u, 1u, 0u,  
    4u, 0u, 1u, 0u, 2u, 0u, 1u, 0u, 3u, 0u, 1u, 0u, 2u, 0u, 1u, 0u,  
    7u, 0u, 1u, 0u, 2u, 0u, 1u, 0u, 3u, 0u, 1u, 0u, 2u, 0u, 1u, 0u,  
    4u, 0u, 1u, 0u, 2u, 0u, 1u, 0u, 3u, 0u, 1u, 0u, 2u, 0u, 1u, 0u,  
    5u, 0u, 1u, 0u, 2u, 0u, 1u, 0u, 3u, 0u, 1u, 0u, 2u, 0u, 1u, 0u,  
    4u, 0u, 1u, 0u, 2u, 0u, 1u, 0u, 3u, 0u, 1u, 0u, 2u, 0u, 1u, 0u,  
    6u, 0u, 1u, 0u, 2u, 0u, 1u, 0u, 3u, 0u, 1u, 0u, 2u, 0u, 1u, 0u,  
    4u, 0u, 1u, 0u, 2u, 0u, 1u, 0u, 3u, 0u, 1u, 0u, 2u, 0u, 1u, 0u,  
    5u, 0u, 1u, 0u, 2u, 0u, 1u, 0u, 3u, 0u, 1u, 0u, 2u, 0u, 1u, 0u,  
    4u, 0u, 1u, 0u, 2u, 0u, 1u, 0u, 3u, 0u, 1u, 0u, 2u, 0u, 1u, 0u   
};






 

static  void  OS_InitEventList(void);

static  void  OS_InitMisc(void);

static  void  OS_InitRdyList(void);

static  void  OS_InitTaskIdle(void);


static  void  OS_InitTaskStat(void);


static  void  OS_InitTCBList(void);

static  void  OS_SchedNew(void);


























 


INT8U  OSEventNameGet (OS_EVENT   *pevent,
                       INT8U     **pname,
                       INT8U      *perr)
{
    INT8U      len;

    OS_CPU_SR  cpu_sr = 0u;




#line 134 "Source\\os_core.c"


    if (pevent == (OS_EVENT *)0) {                
        *perr = 4u;
        return (0u);
    }
    if (pname == (INT8U **)0) {                    
        *perr = 12u;
        return (0u);
    }

    if (OSIntNesting > 0u) {                      
        *perr  = 17u;
        return (0u);
    }
    switch (pevent->OSEventType) {
        case 3u:
        case 4u:
        case 1u:
        case 2u:
             break;

        default:
             *perr = 1u;
             return (0u);
    }
    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    *pname = pevent->OSEventName;
    len    = OS_StrLen(*pname);
    do { OS_CPU_SR_Restore(cpu_sr);} while (0);
    *perr  = 0u;
    return (len);
}



























 


void  OSEventNameSet (OS_EVENT  *pevent,
                      INT8U     *pname,
                      INT8U     *perr)
{

    OS_CPU_SR  cpu_sr = 0u;




#line 213 "Source\\os_core.c"


    if (pevent == (OS_EVENT *)0) {                
        *perr = 4u;
        return;
    }
    if (pname == (INT8U *)0) {                    
        *perr = 12u;
        return;
    }

    if (OSIntNesting > 0u) {                      
        *perr = 18u;
        return;
    }
    switch (pevent->OSEventType) {
        case 3u:
        case 4u:
        case 1u:
        case 2u:
             break;

        default:
             *perr = 1u;
             return;
    }
    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    pevent->OSEventName = pname;
    do { OS_CPU_SR_Restore(cpu_sr);} while (0);
    ;
    *perr = 0u;
}








































































 


INT16U  OSEventPendMulti (OS_EVENT  **pevents_pend,
                          OS_EVENT  **pevents_rdy,
                          void      **pmsgs_rdy,
                          INT32U      timeout,
                          INT8U      *perr)
{
    OS_EVENT  **pevents;
    OS_EVENT   *pevent;

    OS_Q       *pq;

    BOOLEAN     events_rdy;
    INT16U      events_rdy_nbr;
    INT8U       events_stat;

    OS_CPU_SR   cpu_sr = 0u;




#line 346 "Source\\os_core.c"


    if (pevents_pend == (OS_EVENT **)0) {                
       *perr =  4u;
        return (0u);
    }
    if (*pevents_pend  == (OS_EVENT *)0) {               
       *perr =  4u;
        return (0u);
    }
    if (pevents_rdy  == (OS_EVENT **)0) {                
       *perr =  4u;
        return (0u);
    }
    if (pmsgs_rdy == (void **)0) {                       
       *perr =  4u;
        return (0u);
    }


   *pevents_rdy = (OS_EVENT *)0;                         

    pevents     =  pevents_pend;
    pevent      = *pevents;
    while  (pevent != (OS_EVENT *)0) {
        switch (pevent->OSEventType) {                   

            case 3u:
                 break;


            case 1u:
                 break;


            case 2u:
                 break;


            case 4u:
            case 5u:
            default:
                *perr = 1u;
                 return (0u);
        }
        pevents++;
        pevent = *pevents;
    }

    if (OSIntNesting  > 0u) {                            
       *perr =  2u;                         
        return (0u);
    }
    if (OSLockNesting > 0u) {                            
       *perr =  13u;                      
        return (0u);
    }

    events_rdy     =  0u;
    events_rdy_nbr =  0u;
    events_stat    =  0x00u;
    pevents        =  pevents_pend;
    pevent         = *pevents;
    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    while (pevent != (OS_EVENT *)0) {                    
        switch (pevent->OSEventType) {

            case 3u:
                 if (pevent->OSEventCnt > 0u) {          
                     pevent->OSEventCnt--;               
                    *pevents_rdy++ =  pevent;            
                      events_rdy   =  1u;
                    *pmsgs_rdy++   = (void *)0;          
                      events_rdy_nbr++;

                 } else {
                      events_stat |=  0x01u;       
                 }
                 break;



            case 1u:
                 if (pevent->OSEventPtr != (void *)0) {  
                                                         
                    *pmsgs_rdy++         = (void *)pevent->OSEventPtr;
                     pevent->OSEventPtr  = (void *)0;
                    *pevents_rdy++       =  pevent;      
                      events_rdy         =  1u;
                      events_rdy_nbr++;

                 } else {
                      events_stat |= 0x02u;       
                 }
                 break;



            case 2u:
                 pq = (OS_Q *)pevent->OSEventPtr;
                 if (pq->OSQEntries > 0u) {              
                                                         
                    *pmsgs_rdy++ = (void *)*pq->OSQOut++;
                     if (pq->OSQOut == pq->OSQEnd) {     
                         pq->OSQOut  = pq->OSQStart;     
                     }
                     pq->OSQEntries--;                   
                    *pevents_rdy++ = pevent;             
                      events_rdy   = 1u;
                      events_rdy_nbr++;

                 } else {
                      events_stat |= 0x04u;          
                 }
                 break;


            case 4u:
            case 5u:
            default:
                 do { OS_CPU_SR_Restore(cpu_sr);} while (0);
                *pevents_rdy = (OS_EVENT *)0;            
                *perr        =  1u;
                 return (events_rdy_nbr);
        }
        pevents++;
        pevent = *pevents;
    }

    if ( events_rdy == 1u) {                        
       *pevents_rdy = (OS_EVENT *)0;                     
        do { OS_CPU_SR_Restore(cpu_sr);} while (0);
       *perr        =  0u;
        return (events_rdy_nbr);
    }

                                                         
    OSTCBCur->OSTCBStat     |= events_stat  |            
                               0x80u;            
    OSTCBCur->OSTCBStatPend  = 0u;
    OSTCBCur->OSTCBDly       = timeout;                  
    OS_EventTaskWaitMulti(pevents_pend);                 

    do { OS_CPU_SR_Restore(cpu_sr);} while (0);
    OS_Sched();                                          
    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);

    switch (OSTCBCur->OSTCBStatPend) {                   
        case 0u:
        case 2u:
             pevent = OSTCBCur->OSTCBEventMultiRdy;
             if (pevent != (OS_EVENT *)0) {              
                *pevents_rdy++   =  pevent;              
                *pevents_rdy     = (OS_EVENT *)0;        
                  events_rdy_nbr =  1;

             } else {                                    
                 OSTCBCur->OSTCBStatPend = 1u;
                 OS_EventTaskRemoveMulti(OSTCBCur, pevents_pend);
             }
             break;

        case 1u:                            
        default:                                         
             OS_EventTaskRemoveMulti(OSTCBCur, pevents_pend);
             break;
    }

    switch (OSTCBCur->OSTCBStatPend) {
        case 0u:
             switch (pevent->OSEventType) {              

                 case 3u:
                     *pmsgs_rdy++ = (void *)0;           
                      break;




                 case 1u:
                 case 2u:
                     *pmsgs_rdy++ = (void *)OSTCBCur->OSTCBMsg;      
                      break;


                 case 4u:
                 case 5u:
                 default:
                      do { OS_CPU_SR_Restore(cpu_sr);} while (0);
                     *pevents_rdy = (OS_EVENT *)0;       
                     *perr        =  1u;
                      return (events_rdy_nbr);
             }
            *perr = 0u;
             break;

        case 2u:
            *pmsgs_rdy++ = (void *)0;                    
            *perr        =  14u;           
             break;

        case 1u:
        default:
            *pmsgs_rdy++ = (void *)0;                    
            *perr        =  10u;              
             break;
    }

    OSTCBCur->OSTCBStat          =  0x00u;         
    OSTCBCur->OSTCBStatPend      =  0u;     
    OSTCBCur->OSTCBEventMultiPtr = (OS_EVENT **)0;       
    OSTCBCur->OSTCBEventMultiRdy = (OS_EVENT  *)0;


    OSTCBCur->OSTCBMsg           = (void      *)0;       

    do { OS_CPU_SR_Restore(cpu_sr);} while (0);

    return (events_rdy_nbr);
}














 

void  OSInit (void)
{






    OSInitHookBegin();                                            

    OS_InitMisc();                                                

    OS_InitRdyList();                                             

    OS_InitTCBList();                                             

    OS_InitEventList();                                           


    OS_FlagInit();                                                



    OS_MemInit();                                                 



    OS_QInit();                                                   


#line 620 "Source\\os_core.c"

    OS_InitTaskIdle();                                            

    OS_InitTaskStat();                                            



    OSTmr_Init();                                                 


    OSInitHookEnd();                                              


    OSDebugInit();

}

























 

void  OSIntEnter (void)
{
    if (OSRunning == 1u) {
        if (OSIntNesting < 255u) {
            OSIntNesting++;                       
        }
        ;
    }
}



















 

void  OSIntExit (void)
{

    OS_CPU_SR  cpu_sr = 0u;




    if (OSRunning == 1u) {
        do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
        if (OSIntNesting > 0u) {                            
            OSIntNesting--;
        }
        if (OSIntNesting == 0u) {                           
            if (OSLockNesting == 0u) {                      
                OS_SchedNew();
                OSTCBHighRdy = OSTCBPrioTbl[OSPrioHighRdy];
                if (OSPrioHighRdy != OSPrioCur) {           

                    OSTCBHighRdy->OSTCBCtxSwCtr++;          

                    OSCtxSwCtr++;                           






                    ;

                    OSIntCtxSw();                           
                } else {
                    ;
                }
            } else {
                ;
            }
        } else {
            ;
        }

        do { OS_CPU_SR_Restore(cpu_sr);} while (0);
    }
}

















 

#line 763 "Source\\os_core.c"
















 


void  OSSchedLock (void)
{

    OS_CPU_SR  cpu_sr = 0u;




    if (OSRunning == 1u) {                   
        do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
        if (OSIntNesting == 0u) {                 
            if (OSLockNesting < 255u) {           
                OSLockNesting++;                  
            }
        }
        do { OS_CPU_SR_Restore(cpu_sr);} while (0);
    }
}
















 


void  OSSchedUnlock (void)
{

    OS_CPU_SR  cpu_sr = 0u;




    if (OSRunning == 1u) {                             
        do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
        if (OSIntNesting == 0u) {                           
            if (OSLockNesting > 0u) {                       
                OSLockNesting--;                            
                if (OSLockNesting == 0u) {                  
                    do { OS_CPU_SR_Restore(cpu_sr);} while (0);
                    OS_Sched();                             
                } else {
                    do { OS_CPU_SR_Restore(cpu_sr);} while (0);
                }
            } else {
                do { OS_CPU_SR_Restore(cpu_sr);} while (0);
            }
        } else {
            do { OS_CPU_SR_Restore(cpu_sr);} while (0);
        }
    }
}





















 

void  OSStart (void)
{
    if (OSRunning == 0u) {
        OS_SchedNew();                                
        OSPrioCur     = OSPrioHighRdy;
        OSTCBHighRdy  = OSTCBPrioTbl[OSPrioHighRdy];  
        OSTCBCur      = OSTCBHighRdy;
        OSStartHighRdy();                             
    }
}




















 


void  OSStatInit (void)
{

    OS_CPU_SR  cpu_sr = 0u;




    OSTimeDly(2u);                                
    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    OSIdleCtr    = 0uL;                           
    do { OS_CPU_SR_Restore(cpu_sr);} while (0);
    OSTimeDly(1000u / 10u);            
    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    OSIdleCtrMax = OSIdleCtr;                     
    OSStatRdy    = 1u;
    do { OS_CPU_SR_Restore(cpu_sr);} while (0);
}















 

void  OSTimeTick (void)
{
    OS_TCB    *ptcb;

    BOOLEAN    step;


    OS_CPU_SR  cpu_sr = 0u;





    OSTimeTickHook();                                       


    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);                                    
    OSTime++;
    ;
    do { OS_CPU_SR_Restore(cpu_sr);} while (0);

    if (OSRunning == 1u) {

        switch (OSTickStepState) {                          
            case 0u:                          
                 step = 1u;
                 break;

            case 1u:                         
                 step = 0u;                           
                 break;

            case 2u:                         
                 step            = 1u;                 
                 OSTickStepState = 1u;
                 break;

            default:                                        
                 step            = 1u;
                 OSTickStepState = 0u;
                 break;
        }
        if (step == 0u) {                             
            return;
        }

        ptcb = OSTCBList;                                   
        while (ptcb->OSTCBPrio != (63u)) {      
            do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
            if (ptcb->OSTCBDly != 0u) {                     
                ptcb->OSTCBDly--;                           
                if (ptcb->OSTCBDly == 0u) {                 

                    if ((ptcb->OSTCBStat & (0x01u | 0x02u | 0x04u | 0x10u | 0x20u)) != 0x00u) {
                        ptcb->OSTCBStat  &= (INT8U)~(INT8U)(0x01u | 0x02u | 0x04u | 0x10u | 0x20u);    
                        ptcb->OSTCBStatPend = 1u;                  
                    } else {
                        ptcb->OSTCBStatPend = 0u;
                    }

                    if ((ptcb->OSTCBStat & 0x08u) == 0x00u) {   
                        OSRdyGrp               |= ptcb->OSTCBBitY;              
                        OSRdyTbl[ptcb->OSTCBY] |= ptcb->OSTCBBitX;
                        ;
                    }
                }
            }
            ptcb = ptcb->OSTCBNext;                         
            do { OS_CPU_SR_Restore(cpu_sr);} while (0);
        }
    }
}














 

INT16U  OSVersion (void)
{
    return (29300u);
}












 


void  OS_Dummy (void)
{
}





























 

INT8U  OS_EventTaskRdy (OS_EVENT  *pevent,
                        void      *pmsg,
                        INT8U      msk,
                        INT8U      pend_stat)
{
    OS_TCB   *ptcb;
    INT8U     y;
    INT8U     x;
    INT8U     prio;






    y    = OSUnMapTbl[pevent->OSEventGrp];               
    x    = OSUnMapTbl[pevent->OSEventTbl[y]];
    prio = (INT8U)((y << 3u) + x);                       
#line 1110 "Source\\os_core.c"

    ptcb                  =  OSTCBPrioTbl[prio];         
    ptcb->OSTCBDly        =  0u;                         

    ptcb->OSTCBMsg        =  pmsg;                       



    ptcb->OSTCBStat      &= (INT8U)~msk;                 
    ptcb->OSTCBStatPend   =  pend_stat;                  
                                                         
    if ((ptcb->OSTCBStat &   0x08u) == 0x00u) {
        OSRdyGrp         |=  ptcb->OSTCBBitY;            
        OSRdyTbl[y]      |=  ptcb->OSTCBBitX;
        ;
    }

    OS_EventTaskRemove(ptcb, pevent);                    

    if (ptcb->OSTCBEventMultiPtr != (OS_EVENT **)0) {    
        OS_EventTaskRemoveMulti(ptcb, ptcb->OSTCBEventMultiPtr);
        ptcb->OSTCBEventMultiPtr  = (OS_EVENT **)0;      
        ptcb->OSTCBEventMultiRdy  = (OS_EVENT  *)pevent; 
    }


    return (prio);
}
















 

void  OS_EventTaskWait (OS_EVENT *pevent)
{
    INT8U  y;


    OSTCBCur->OSTCBEventPtr               = pevent;                  

    pevent->OSEventTbl[OSTCBCur->OSTCBY] |= OSTCBCur->OSTCBBitX;     
    pevent->OSEventGrp                   |= OSTCBCur->OSTCBBitY;

    y             =  OSTCBCur->OSTCBY;             
    OSRdyTbl[y]  &= (OS_PRIO)~OSTCBCur->OSTCBBitX;
    ;
    if (OSRdyTbl[y] == 0u) {                       
        OSRdyGrp &= (OS_PRIO)~OSTCBCur->OSTCBBitY;
    }
}

















 

void  OS_EventTaskWaitMulti (OS_EVENT **pevents_wait)
{
    OS_EVENT **pevents;
    OS_EVENT  *pevent;
    INT8U      y;


    OSTCBCur->OSTCBEventMultiPtr = (OS_EVENT **)pevents_wait;        
    OSTCBCur->OSTCBEventMultiRdy = (OS_EVENT  *)0;

    pevents =  pevents_wait;
    pevent  = *pevents;
    while (pevent != (OS_EVENT *)0) {                                
        pevent->OSEventTbl[OSTCBCur->OSTCBY] |= OSTCBCur->OSTCBBitX;
        pevent->OSEventGrp                   |= OSTCBCur->OSTCBBitY;
        pevents++;
        pevent = *pevents;
    }

    y             =  OSTCBCur->OSTCBY;             
    OSRdyTbl[y]  &= (OS_PRIO)~OSTCBCur->OSTCBBitX;
    ;
    if (OSRdyTbl[y] == 0u) {                       
        OSRdyGrp &= (OS_PRIO)~OSTCBCur->OSTCBBitY;
    }
}

















 

void  OS_EventTaskRemove (OS_TCB   *ptcb,
                          OS_EVENT *pevent)
{
    INT8U  y;


    y                       =  ptcb->OSTCBY;
    pevent->OSEventTbl[y]  &= (OS_PRIO)~ptcb->OSTCBBitX;     
    if (pevent->OSEventTbl[y] == 0u) {
        pevent->OSEventGrp &= (OS_PRIO)~ptcb->OSTCBBitY;
    }
    ptcb->OSTCBEventPtr     = (OS_EVENT  *)0;                
}

















 

void  OS_EventTaskRemoveMulti (OS_TCB    *ptcb,
                               OS_EVENT **pevents_multi)
{
    OS_EVENT **pevents;
    OS_EVENT  *pevent;
    INT8U      y;
    OS_PRIO    bity;
    OS_PRIO    bitx;


    y       =  ptcb->OSTCBY;
    bity    =  ptcb->OSTCBBitY;
    bitx    =  ptcb->OSTCBBitX;
    pevents =  pevents_multi;
    pevent  = *pevents;
    while (pevent != (OS_EVENT *)0) {                    
        pevent->OSEventTbl[y]  &= (OS_PRIO)~bitx;
        if (pevent->OSEventTbl[y] == 0u) {
            pevent->OSEventGrp &= (OS_PRIO)~bity;
        }
        pevents++;
        pevent = *pevents;
    }
}















 

void  OS_EventWaitListInit (OS_EVENT *pevent)
{
    INT8U  i;


    pevent->OSEventGrp = 0u;                      
    for (i = 0u; i < ((63u) / 8u + 1u); i++) {
        pevent->OSEventTbl[i] = 0u;
    }
}














 

static  void  OS_InitEventList (void)
{


    INT16U     ix;
    INT16U     ix_next;
    OS_EVENT  *pevent1;
    OS_EVENT  *pevent2;


    OS_MemClr((INT8U *)&OSEventTbl[0], sizeof(OSEventTbl));  
    for (ix = 0u; ix < (10u - 1u); ix++) {         
        ix_next = ix + 1u;
        pevent1 = &OSEventTbl[ix];
        pevent2 = &OSEventTbl[ix_next];
        pevent1->OSEventType    = 0u;
        pevent1->OSEventPtr     = pevent2;

        pevent1->OSEventName    = (INT8U *)(void *)"?";      

    }
    pevent1                         = &OSEventTbl[ix];
    pevent1->OSEventType            = 0u;
    pevent1->OSEventPtr             = (OS_EVENT *)0;

    pevent1->OSEventName            = (INT8U *)(void *)"?";  

    OSEventFreeList                 = &OSEventTbl[0];
#line 1373 "Source\\os_core.c"
}













 

static  void  OS_InitMisc (void)
{

    OSTime                    = 0uL;                        


    OSIntNesting              = 0u;                         
    OSLockNesting             = 0u;                         

    OSTaskCtr                 = 0u;                         

    OSRunning                 = 0u;                   

    OSCtxSwCtr                = 0u;                         
    OSIdleCtr                 = 0uL;                        


    OSIdleCtrRun              = 0uL;
    OSIdleCtrMax              = 0uL;
    OSStatRdy                 = 0u;                   







    OSTaskRegNextAvailID      = 0u;                         

}













 

static  void  OS_InitRdyList (void)
{
    INT8U  i;


    OSRdyGrp      = 0u;                                     
    for (i = 0u; i < ((63u) / 8u + 1u); i++) {
        OSRdyTbl[i] = 0u;
    }

    OSPrioCur     = 0u;
    OSPrioHighRdy = 0u;

    OSTCBHighRdy  = (OS_TCB *)0;
    OSTCBCur      = (OS_TCB *)0;
}













 

static  void  OS_InitTaskIdle (void)
{

    INT8U  err;





    (void)OSTaskCreateExt(OS_TaskIdle,
                          (void *)0,                                  
                          &OSTaskIdleStk[128u - 1u], 
                          (63u),                          
                          65535u,
                          &OSTaskIdleStk[0],                          
                          128u,
                          (void *)0,                                  
                          0x0001u | 0x0002u); 
#line 1507 "Source\\os_core.c"


    OSTaskNameSet((63u), (INT8U *)(void *)"uC/OS-II Idle", &err);

}













 


static  void  OS_InitTaskStat (void)
{

    INT8U  err;





    (void)OSTaskCreateExt(OS_TaskStat,
                          (void *)0,                                    
                          &OSTaskStatStk[128u - 1u],   
                          (63u - 1u),                            
                          65534u,
                          &OSTaskStatStk[0],                            
                          128u,
                          (void *)0,                                    
                          0x0001u | 0x0002u);   
#line 1570 "Source\\os_core.c"


    OSTaskNameSet((63u - 1u), (INT8U *)(void *)"uC/OS-II Stat", &err);

}














 

static  void  OS_InitTCBList (void)
{
    INT8U    ix;
    INT8U    ix_next;
    OS_TCB  *ptcb1;
    OS_TCB  *ptcb2;


    OS_MemClr((INT8U *)&OSTCBTbl[0],     sizeof(OSTCBTbl));       
    OS_MemClr((INT8U *)&OSTCBPrioTbl[0], sizeof(OSTCBPrioTbl));   
    for (ix = 0u; ix < (20u + 2u - 1u); ix++) {     
        ix_next =  ix + 1u;
        ptcb1   = &OSTCBTbl[ix];
        ptcb2   = &OSTCBTbl[ix_next];
        ptcb1->OSTCBNext = ptcb2;

        ptcb1->OSTCBTaskName = (INT8U *)(void *)"?";              

    }
    ptcb1                   = &OSTCBTbl[ix];
    ptcb1->OSTCBNext        = (OS_TCB *)0;                        

    ptcb1->OSTCBTaskName    = (INT8U *)(void *)"?";               

    OSTCBList               = (OS_TCB *)0;                        
    OSTCBFreeList           = &OSTCBTbl[0];
}




















 

void  OS_MemClr (INT8U  *pdest,
                 INT16U  size)
{
    while (size > 0u) {
        *pdest++ = (INT8U)0;
        size--;
    }
}
























 

void  OS_MemCopy (INT8U  *pdest,
                  INT8U  *psrc,
                  INT16U  size)
{
    while (size > 0u) {
        *pdest++ = *psrc++;
        size--;
    }
}

















 

void  OS_Sched (void)
{

    OS_CPU_SR  cpu_sr = 0u;




    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    if (OSIntNesting == 0u) {                           
        if (OSLockNesting == 0u) {                      
            OS_SchedNew();
            OSTCBHighRdy = OSTCBPrioTbl[OSPrioHighRdy];
            if (OSPrioHighRdy != OSPrioCur) {           

                OSTCBHighRdy->OSTCBCtxSwCtr++;          

                OSCtxSwCtr++;                           







                OSCtxSw();                           
            }
        }
    }
    do { OS_CPU_SR_Restore(cpu_sr);} while (0);
}
















 

static  void  OS_SchedNew (void)
{

    INT8U   y;


    y             = OSUnMapTbl[OSRdyGrp];
    OSPrioHighRdy = (INT8U)((y << 3u) + OSUnMapTbl[OSRdyTbl[y]]);
#line 1776 "Source\\os_core.c"
}
















 


INT8U  OS_StrLen (INT8U *psrc)
{
    INT8U  len;



    if (psrc == (INT8U *)0) {
        return (0u);
    }


    len = 0u;
    while (*psrc != (INT8U)0) {
        psrc++;
        len++;
    }
    return (len);
}






















 

void  OS_TaskIdle (void *p_arg)
{

    OS_CPU_SR  cpu_sr = 0u;


    (void)p_arg;                                  
    for (;;) {
        do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
        OSIdleCtr++;
        do { OS_CPU_SR_Restore(cpu_sr);} while (0);
        OSTaskIdleHook();                         
    }
}
























 


void  OS_TaskStat (void *p_arg)
{
    INT8S  usage;

    OS_CPU_SR  cpu_sr = 0u;




    p_arg = p_arg;                                
    while (OSStatRdy == 0u) {
        OSTimeDly(2u * 1000u / 10u);   
    }
    OSIdleCtrMax /= 100uL;
    if (OSIdleCtrMax == 0uL) {
        OSCPUUsage = 0u;

        (void)OSTaskSuspend(0xFFu);





    }
    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    OSIdleCtr = OSIdleCtrMax * 100uL;             
    do { OS_CPU_SR_Restore(cpu_sr);} while (0);
    for (;;) {
        OSTimeDly(1);                             

        do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
        OSIdleCtr = 0uL;                         
        do { OS_CPU_SR_Restore(cpu_sr);} while (0);

        OSTimeDly(1000u / 10u);        

        do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
        OSIdleCtrRun = OSIdleCtr;                 
        do { OS_CPU_SR_Restore(cpu_sr);} while (0);

        usage            = 100 - (INT8S)(OSIdleCtrRun / OSIdleCtrMax);
        if (usage >= 0) {                         
            OSCPUUsage   = (INT8U)usage;
        } else {
            OSCPUUsage   = 0u;
            OSIdleCtrMax = OSIdleCtrRun / 100uL;  
        }

        OSTaskStatHook();                         

        OS_TaskStatStkChk();                      

    }
}













 


void  OS_TaskStatStkChk (void)
{
    OS_TCB      *ptcb;
    OS_STK_DATA  stk_data;
    INT8U        err;
    INT8U        prio;


    for (prio = 0u; prio <= (63u); prio++) {
        err = OSTaskStkChk(prio, &stk_data);
        if (err == 0u) {
            ptcb = OSTCBPrioTbl[prio];
            if (ptcb != (OS_TCB *)0) {                                
                if (ptcb != ((OS_TCB *)1)) {                        


                    ptcb->OSTCBStkBase = ptcb->OSTCBStkBottom + ptcb->OSTCBStkSize;



                    ptcb->OSTCBStkUsed = stk_data.OSUsed;             

                }
            }
        }
    }
}












































 

INT8U  OS_TCBInit (INT8U    prio,
                   OS_STK  *ptos,
                   OS_STK  *pbos,
                   INT16U   id,
                   INT32U   stk_size,
                   void    *pext,
                   INT16U   opt)
{
    OS_TCB    *ptcb;

    OS_CPU_SR  cpu_sr = 0u;


    INT8U      i;
#line 2042 "Source\\os_core.c"


    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    ptcb = OSTCBFreeList;                                   
    if (ptcb != (OS_TCB *)0) {
        OSTCBFreeList            = ptcb->OSTCBNext;         
        do { OS_CPU_SR_Restore(cpu_sr);} while (0);
        ptcb->OSTCBStkPtr        = ptos;                    
        ptcb->OSTCBPrio          = prio;                    
        ptcb->OSTCBStat          = 0x00u;             
        ptcb->OSTCBStatPend      = 0u;         
        ptcb->OSTCBDly           = 0u;                      


        ptcb->OSTCBExtPtr        = pext;                    
        ptcb->OSTCBStkSize       = stk_size;                
        ptcb->OSTCBStkBottom     = pbos;                    
        ptcb->OSTCBOpt           = opt;                     
        ptcb->OSTCBId            = id;                      
#line 2068 "Source\\os_core.c"


        ptcb->OSTCBDelReq        = 0u;



        ptcb->OSTCBY             = (INT8U)(prio >> 3u);
        ptcb->OSTCBX             = (INT8U)(prio & 0x07u);




                                                                   
        ptcb->OSTCBBitY          = (OS_PRIO)(1uL << ptcb->OSTCBY);
        ptcb->OSTCBBitX          = (OS_PRIO)(1uL << ptcb->OSTCBX);


        ptcb->OSTCBEventPtr      = (OS_EVENT  *)0;          

        ptcb->OSTCBEventMultiPtr = (OS_EVENT **)0;          
        ptcb->OSTCBEventMultiRdy = (OS_EVENT  *)0;          




        ptcb->OSTCBFlagNode      = (OS_FLAG_NODE *)0;       



        ptcb->OSTCBMsg           = (void *)0;               



        ptcb->OSTCBCtxSwCtr      = 0uL;                     
        ptcb->OSTCBCyclesStart   = 0uL;
        ptcb->OSTCBCyclesTot     = 0uL;
        ptcb->OSTCBStkBase       = (OS_STK *)0;
        ptcb->OSTCBStkUsed       = 0uL;



        ptcb->OSTCBTaskName      = (INT8U *)(void *)"?";



        for (i = 0u; i < 1u; i++) {
            ptcb->OSTCBRegTbl[i] = 0u;
        }


        OSTCBInitHook(ptcb);

        do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
        OSTCBPrioTbl[prio] = ptcb;
        do { OS_CPU_SR_Restore(cpu_sr);} while (0);

        OSTaskCreateHook(ptcb);                             

#line 2134 "Source\\os_core.c"

        do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
        ptcb->OSTCBNext = OSTCBList;                        
        ptcb->OSTCBPrev = (OS_TCB *)0;
        if (OSTCBList != (OS_TCB *)0) {
            OSTCBList->OSTCBPrev = ptcb;
        }
        OSTCBList               = ptcb;
        OSRdyGrp               |= ptcb->OSTCBBitY;          
        OSRdyTbl[ptcb->OSTCBY] |= ptcb->OSTCBBitX;
        OSTaskCtr++;                                        
        ;
        do { OS_CPU_SR_Restore(cpu_sr);} while (0);
        return (0u);
    }
    do { OS_CPU_SR_Restore(cpu_sr);} while (0);
    return (66u);
}

