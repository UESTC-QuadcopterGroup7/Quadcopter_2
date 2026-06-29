#line 1 "Source\\os_flag.c"














 










 






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





 

extern  INT32U            OSCtxSwCtr;                


extern  OS_EVENT         *OSEventFreeList;           
extern  OS_EVENT          OSEventTbl[10u]; 



extern  OS_FLAG_GRP       OSFlagTbl[5u];   
extern  OS_FLAG_GRP      *OSFlagFreeList;            



extern  INT8U             OSCPUUsage;                
extern  INT32U            OSIdleCtrMax;              
extern  INT32U            OSIdleCtrRun;              
extern  BOOLEAN           OSStatRdy;                 
extern  OS_STK            OSTaskStatStk[128u];       


extern  INT8U             OSIntNesting;              

extern  INT8U             OSLockNesting;             

extern  INT8U             OSPrioCur;                 
extern  INT8U             OSPrioHighRdy;             

extern  OS_PRIO           OSRdyGrp;                         
extern  OS_PRIO           OSRdyTbl[((63u) / 8u + 1u)];        

extern  BOOLEAN           OSRunning;                        

extern  INT8U             OSTaskCtr;                        

extern  volatile  INT32U  OSIdleCtr;                                  





extern  OS_STK            OSTaskIdleStk[128u];       


extern  OS_TCB           *OSTCBCur;                         
extern  OS_TCB           *OSTCBFreeList;                    
extern  OS_TCB           *OSTCBHighRdy;                     
extern  OS_TCB           *OSTCBList;                        
extern  OS_TCB           *OSTCBPrioTbl[63u + 1u];     
extern  OS_TCB            OSTCBTbl[20u + 2u];    


extern  INT8U             OSTickStepState;           



extern  OS_MEM           *OSMemFreeList;             
extern  OS_MEM            OSMemTbl[5u]; 



extern  OS_Q             *OSQFreeList;               
extern  OS_Q              OSQTbl[4u];         



extern  INT8U             OSTaskRegNextAvailID;      



extern  volatile  INT32U  OSTime;                    



extern  INT16U            OSTmrFree;                 
extern  INT16U            OSTmrUsed;                 
extern  INT32U            OSTmrTime;                 

extern  OS_EVENT         *OSTmrSem;                  
extern  OS_EVENT         *OSTmrSemSignal;            

extern  OS_TMR            OSTmrTbl[16u];  
extern  OS_TMR           *OSTmrFreeList;             
extern  OS_STK            OSTmrTaskStk[128u];

extern  OS_TMR_WHEEL      OSTmrWheelTbl[7u];


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





#line 35 "Source\\os_flag.c"







 

static  void     OS_FlagBlock(OS_FLAG_GRP *pgrp, OS_FLAG_NODE *pnode, OS_FLAGS flags, INT8U wait_type, INT32U timeout);
static  BOOLEAN  OS_FlagTaskRdy(OS_FLAG_NODE *pnode, OS_FLAGS flags_rdy, INT8U pend_stat);




















































 


OS_FLAGS  OSFlagAccept (OS_FLAG_GRP  *pgrp,
                        OS_FLAGS      flags,
                        INT8U         wait_type,
                        INT8U        *perr)
{
    OS_FLAGS      flags_rdy;
    INT8U         result;
    BOOLEAN       consume;

    OS_CPU_SR     cpu_sr = 0u;




#line 121 "Source\\os_flag.c"


    if (pgrp == (OS_FLAG_GRP *)0) {                         
        *perr = 110u;
        return ((OS_FLAGS)0);
    }

    if (pgrp->OSFlagType != 5u) {           
        *perr = 1u;
        return ((OS_FLAGS)0);
    }
    result = (INT8U)(wait_type & 0x80u);
    if (result != (INT8U)0) {                               
        wait_type &= ~0x80u;
        consume    = 1u;
    } else {
        consume    = 0u;
    }

    *perr = 0u;                                    
    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    switch (wait_type) {
        case 2u:                          
             flags_rdy = (OS_FLAGS)(pgrp->OSFlagFlags & flags);      
             if (flags_rdy == flags) {                      
                 if (consume == 1u) {                  
                     pgrp->OSFlagFlags &= (OS_FLAGS)~flags_rdy;      
                 }
             } else {
                 *perr = 112u;
             }
             do { OS_CPU_SR_Restore(cpu_sr);} while (0);
             break;

        case 3u:
             flags_rdy = (OS_FLAGS)(pgrp->OSFlagFlags & flags);      
             if (flags_rdy != (OS_FLAGS)0) {                
                 if (consume == 1u) {                  
                     pgrp->OSFlagFlags &= (OS_FLAGS)~flags_rdy;      
                 }
             } else {
                 *perr = 112u;
             }
             do { OS_CPU_SR_Restore(cpu_sr);} while (0);
             break;


        case 0u:                          
             flags_rdy = (OS_FLAGS)~pgrp->OSFlagFlags & flags;     
             if (flags_rdy == flags) {                      
                 if (consume == 1u) {                  
                     pgrp->OSFlagFlags |= flags_rdy;        
                 }
             } else {
                 *perr = 112u;
             }
             do { OS_CPU_SR_Restore(cpu_sr);} while (0);
             break;

        case 1u:
             flags_rdy = (OS_FLAGS)~pgrp->OSFlagFlags & flags;    
             if (flags_rdy != (OS_FLAGS)0) {                
                 if (consume == 1u) {                  
                     pgrp->OSFlagFlags |= flags_rdy;        
                 }
             } else {
                 *perr = 112u;
             }
             do { OS_CPU_SR_Restore(cpu_sr);} while (0);
             break;


        default:
             do { OS_CPU_SR_Restore(cpu_sr);} while (0);
             flags_rdy = (OS_FLAGS)0;
             *perr     = 111u;
             break;
    }
    return (flags_rdy);
}























 

OS_FLAG_GRP  *OSFlagCreate (OS_FLAGS  flags,
                            INT8U    *perr)
{
    OS_FLAG_GRP *pgrp;

    OS_CPU_SR    cpu_sr = 0u;




#line 242 "Source\\os_flag.c"

#line 250 "Source\\os_flag.c"

    if (OSIntNesting > 0u) {                         
        *perr = 16u;                   
        return ((OS_FLAG_GRP *)0);
    }
    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    pgrp = OSFlagFreeList;                           
    if (pgrp != (OS_FLAG_GRP *)0) {                  
                                                     
        OSFlagFreeList       = (OS_FLAG_GRP *)OSFlagFreeList->OSFlagWaitList;
        pgrp->OSFlagType     = 5u;   
        pgrp->OSFlagFlags    = flags;                
        pgrp->OSFlagWaitList = (void *)0;            

        pgrp->OSFlagName     = (INT8U *)(void *)"?";

        ;
        do { OS_CPU_SR_Restore(cpu_sr);} while (0);
        *perr                = 0u;
    } else {
        do { OS_CPU_SR_Restore(cpu_sr);} while (0);
        *perr                = 114u;
    }
    return (pgrp);                                   
}








































 


OS_FLAG_GRP  *OSFlagDel (OS_FLAG_GRP  *pgrp,
                         INT8U         opt,
                         INT8U        *perr)
{
    BOOLEAN       tasks_waiting;
    OS_FLAG_NODE *pnode;
    OS_FLAG_GRP  *pgrp_return;

    OS_CPU_SR     cpu_sr = 0u;



#line 336 "Source\\os_flag.c"

#line 344 "Source\\os_flag.c"


    if (pgrp == (OS_FLAG_GRP *)0) {                         
        *perr = 110u;
        return (pgrp);
    }


    ;

    if (OSIntNesting > 0u) {                                
        *perr = 15u;                             
        ;
        return (pgrp);
    }
    if (pgrp->OSFlagType != 5u) {           
        *perr = 1u;
        ;
        return (pgrp);
    }
    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    if (pgrp->OSFlagWaitList != (void *)0) {                
        tasks_waiting = 1u;                            
    } else {
        tasks_waiting = 0u;                           
    }
    switch (opt) {
        case 0u:                                
             if (tasks_waiting == 0u) {

                 pgrp->OSFlagName     = (INT8U *)(void *)"?";

                 pgrp->OSFlagType     = 0u;
                 pgrp->OSFlagWaitList = (void *)OSFlagFreeList;  
                 pgrp->OSFlagFlags    = (OS_FLAGS)0;
                 OSFlagFreeList       = pgrp;
                 do { OS_CPU_SR_Restore(cpu_sr);} while (0);
                 *perr                = 0u;
                 pgrp_return          = (OS_FLAG_GRP *)0;   
             } else {
                 do { OS_CPU_SR_Restore(cpu_sr);} while (0);
                 *perr                = 73u;
                 pgrp_return          = pgrp;
             }
             break;

        case 1u:                                 
             pnode = (OS_FLAG_NODE *)pgrp->OSFlagWaitList;
             while (pnode != (OS_FLAG_NODE *)0) {           
                 (void)OS_FlagTaskRdy(pnode, (OS_FLAGS)0, 2u);
                 pnode = (OS_FLAG_NODE *)pnode->OSFlagNodeNext;
             }

             pgrp->OSFlagName     = (INT8U *)(void *)"?";

             pgrp->OSFlagType     = 0u;
             pgrp->OSFlagWaitList = (void *)OSFlagFreeList; 
             pgrp->OSFlagFlags    = (OS_FLAGS)0;
             OSFlagFreeList       = pgrp;
             do { OS_CPU_SR_Restore(cpu_sr);} while (0);
             if (tasks_waiting == 1u) {                
                 OS_Sched();                                
             }
             *perr = 0u;
             pgrp_return          = (OS_FLAG_GRP *)0;       
             break;

        default:
             do { OS_CPU_SR_Restore(cpu_sr);} while (0);
             *perr                = 7u;
             pgrp_return          = pgrp;
             break;
    }

    ;

    return (pgrp_return);
}
























 


INT8U  OSFlagNameGet (OS_FLAG_GRP   *pgrp,
                      INT8U        **pname,
                      INT8U         *perr)
{
    INT8U      len;

    OS_CPU_SR  cpu_sr = 0u;




#line 466 "Source\\os_flag.c"


    if (pgrp == (OS_FLAG_GRP *)0) {               
        *perr = 110u;
        return (0u);
    }
    if (pname == (INT8U **)0) {                    
        *perr = 12u;
        return (0u);
    }

    if (OSIntNesting > 0u) {                      
        *perr = 17u;
        return (0u);
    }
    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    if (pgrp->OSFlagType != 5u) {
        do { OS_CPU_SR_Restore(cpu_sr);} while (0);
        *perr = 1u;
        return (0u);
    }
    *pname = pgrp->OSFlagName;
    len    = OS_StrLen(*pname);
    do { OS_CPU_SR_Restore(cpu_sr);} while (0);
    *perr  = 0u;
    return (len);
}
























 


void  OSFlagNameSet (OS_FLAG_GRP  *pgrp,
                     INT8U        *pname,
                     INT8U        *perr)
{

    OS_CPU_SR  cpu_sr = 0u;




#line 536 "Source\\os_flag.c"


    if (pgrp == (OS_FLAG_GRP *)0) {               
        *perr = 110u;
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
    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    if (pgrp->OSFlagType != 5u) {
        do { OS_CPU_SR_Restore(cpu_sr);} while (0);
        *perr = 1u;
        return;
    }
    pgrp->OSFlagName = pname;
    do { OS_CPU_SR_Restore(cpu_sr);} while (0);
    ;
    *perr            = 0u;
    return;
}























































 

OS_FLAGS  OSFlagPend (OS_FLAG_GRP  *pgrp,
                      OS_FLAGS      flags,
                      INT8U         wait_type,
                      INT32U        timeout,
                      INT8U        *perr)
{
    OS_FLAG_NODE  node;
    OS_FLAGS      flags_rdy;
    INT8U         result;
    INT8U         pend_stat;
    BOOLEAN       consume;

    OS_CPU_SR     cpu_sr = 0u;



#line 642 "Source\\os_flag.c"


    if (pgrp == (OS_FLAG_GRP *)0) {                         
        *perr = 110u;
        return ((OS_FLAGS)0);
    }


    ;

    if (OSIntNesting > 0u) {                                
        *perr = 2u;                            
        ;
        return ((OS_FLAGS)0);
    }
    if (OSLockNesting > 0u) {                               
        *perr = 13u;                         
        ;
        return ((OS_FLAGS)0);
    }
    if (pgrp->OSFlagType != 5u) {           
        *perr = 1u;
        ;
        return ((OS_FLAGS)0);
    }
    result = (INT8U)(wait_type & 0x80u);
    if (result != (INT8U)0) {                               
        wait_type &= (INT8U)~(INT8U)0x80u;
        consume    = 1u;
    } else {
        consume    = 0u;
    }

    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    switch (wait_type) {
        case 2u:                          
             flags_rdy = (OS_FLAGS)(pgrp->OSFlagFlags & flags);    
             if (flags_rdy == flags) {                      
                 if (consume == 1u) {                  
                     pgrp->OSFlagFlags &= (OS_FLAGS)~flags_rdy;    
                 }
                 OSTCBCur->OSTCBFlagsRdy = flags_rdy;       
                 do { OS_CPU_SR_Restore(cpu_sr);} while (0);                        
                 *perr                   = 0u;
                 ;
                 return (flags_rdy);
             } else {                                       
                 OS_FlagBlock(pgrp, &node, flags, wait_type, timeout);
                 do { OS_CPU_SR_Restore(cpu_sr);} while (0);
             }
             break;

        case 3u:
             flags_rdy = (OS_FLAGS)(pgrp->OSFlagFlags & flags);     
             if (flags_rdy != (OS_FLAGS)0) {                
                 if (consume == 1u) {                  
                     pgrp->OSFlagFlags &= (OS_FLAGS)~flags_rdy;     
                 }
                 OSTCBCur->OSTCBFlagsRdy = flags_rdy;       
                 do { OS_CPU_SR_Restore(cpu_sr);} while (0);                        
                 *perr                   = 0u;
                 ;
                 return (flags_rdy);
             } else {                                       
                 OS_FlagBlock(pgrp, &node, flags, wait_type, timeout);
                 do { OS_CPU_SR_Restore(cpu_sr);} while (0);
             }
             break;


        case 0u:                          
             flags_rdy = (OS_FLAGS)~pgrp->OSFlagFlags & flags;     
             if (flags_rdy == flags) {                      
                 if (consume == 1u) {                  
                     pgrp->OSFlagFlags |= flags_rdy;        
                 }
                 OSTCBCur->OSTCBFlagsRdy = flags_rdy;       
                 do { OS_CPU_SR_Restore(cpu_sr);} while (0);                        
                 *perr                   = 0u;
                 ;
                 return (flags_rdy);
             } else {                                       
                 OS_FlagBlock(pgrp, &node, flags, wait_type, timeout);
                 do { OS_CPU_SR_Restore(cpu_sr);} while (0);
             }
             break;

        case 1u:
             flags_rdy = (OS_FLAGS)~pgrp->OSFlagFlags & flags;    
             if (flags_rdy != (OS_FLAGS)0) {                
                 if (consume == 1u) {                  
                     pgrp->OSFlagFlags |= flags_rdy;        
                 }
                 OSTCBCur->OSTCBFlagsRdy = flags_rdy;       
                 do { OS_CPU_SR_Restore(cpu_sr);} while (0);                        
                 *perr                   = 0u;
                 ;
                 return (flags_rdy);
             } else {                                       
                 OS_FlagBlock(pgrp, &node, flags, wait_type, timeout);
                 do { OS_CPU_SR_Restore(cpu_sr);} while (0);
             }
             break;


        default:
             do { OS_CPU_SR_Restore(cpu_sr);} while (0);
             flags_rdy = (OS_FLAGS)0;
             *perr      = 111u;
             ;
             return (flags_rdy);
    }

    OS_Sched();                                             
    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    if (OSTCBCur->OSTCBStatPend != 0u) {       
        pend_stat                = OSTCBCur->OSTCBStatPend;
        OSTCBCur->OSTCBStatPend  = 0u;
        OS_FlagUnlink(&node);
        OSTCBCur->OSTCBStat      = 0x00u;             
        do { OS_CPU_SR_Restore(cpu_sr);} while (0);
        flags_rdy                = (OS_FLAGS)0;
        switch (pend_stat) {
            case 2u:
                 *perr = 14u;                 
                 break;

            case 1u:
            default:
                 *perr = 10u;                    
                 break;
        }
        ;
        return (flags_rdy);
    }
    flags_rdy = OSTCBCur->OSTCBFlagsRdy;
    if (consume == 1u) {                               
        switch (wait_type) {
            case 2u:
            case 3u:                      
                 pgrp->OSFlagFlags &= (OS_FLAGS)~flags_rdy;
                 break;


            case 0u:
            case 1u:                      
                 pgrp->OSFlagFlags |=  flags_rdy;
                 break;

            default:
                 do { OS_CPU_SR_Restore(cpu_sr);} while (0);
                 *perr = 111u;
                 ;
                 return ((OS_FLAGS)0);
        }
    }
    do { OS_CPU_SR_Restore(cpu_sr);} while (0);
    *perr = 0u;                                    
    ;
    return (flags_rdy);
}















 

OS_FLAGS  OSFlagPendGetFlagsRdy (void)
{
    OS_FLAGS      flags;

    OS_CPU_SR     cpu_sr = 0u;




    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    flags = OSTCBCur->OSTCBFlagsRdy;
    do { OS_CPU_SR_Restore(cpu_sr);} while (0);
    return (flags);
}










































 
OS_FLAGS  OSFlagPost (OS_FLAG_GRP  *pgrp,
                      OS_FLAGS      flags,
                      INT8U         opt,
                      INT8U        *perr)
{
    OS_FLAG_NODE *pnode;
    BOOLEAN       sched;
    OS_FLAGS      flags_cur;
    OS_FLAGS      flags_rdy;
    BOOLEAN       rdy;

    OS_CPU_SR     cpu_sr = 0u;



#line 898 "Source\\os_flag.c"


    if (pgrp == (OS_FLAG_GRP *)0) {                   
        *perr = 110u;
        return ((OS_FLAGS)0);
    }


    ;

    if (pgrp->OSFlagType != 5u) {     
        *perr = 1u;
        ;
        return ((OS_FLAGS)0);
    }

    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    switch (opt) {
        case 0u:
             pgrp->OSFlagFlags &= (OS_FLAGS)~flags;   
             break;

        case 1u:
             pgrp->OSFlagFlags |=  flags;             
             break;

        default:
             do { OS_CPU_SR_Restore(cpu_sr);} while (0);                      
             *perr = 113u;
             ;
             return ((OS_FLAGS)0);
    }
    sched = 0u;                                 
    pnode = (OS_FLAG_NODE *)pgrp->OSFlagWaitList;
    while (pnode != (OS_FLAG_NODE *)0) {              
        switch (pnode->OSFlagNodeWaitType) {
            case 2u:                
                 flags_rdy = (OS_FLAGS)(pgrp->OSFlagFlags & pnode->OSFlagNodeFlags);
                 if (flags_rdy == pnode->OSFlagNodeFlags) {    
                     rdy = OS_FlagTaskRdy(pnode, flags_rdy, 0u);
                     if (rdy == 1u) {
                         sched = 1u;                      
                     }
                 }
                 break;

            case 3u:                
                 flags_rdy = (OS_FLAGS)(pgrp->OSFlagFlags & pnode->OSFlagNodeFlags);
                 if (flags_rdy != (OS_FLAGS)0) {               
                     rdy = OS_FlagTaskRdy(pnode, flags_rdy, 0u);
                     if (rdy == 1u) {
                         sched = 1u;                      
                     }
                 }
                 break;


            case 0u:                
                 flags_rdy = (OS_FLAGS)~pgrp->OSFlagFlags & pnode->OSFlagNodeFlags;
                 if (flags_rdy == pnode->OSFlagNodeFlags) {    
                     rdy = OS_FlagTaskRdy(pnode, flags_rdy, 0u);
                     if (rdy == 1u) {
                         sched = 1u;                      
                     }
                 }
                 break;

            case 1u:                
                 flags_rdy = (OS_FLAGS)~pgrp->OSFlagFlags & pnode->OSFlagNodeFlags;
                 if (flags_rdy != (OS_FLAGS)0) {               
                     rdy = OS_FlagTaskRdy(pnode, flags_rdy, 0u);
                     if (rdy == 1u) {
                         sched = 1u;                      
                     }
                 }
                 break;

            default:
                 do { OS_CPU_SR_Restore(cpu_sr);} while (0);
                 *perr = 111u;
                 ;
                 return ((OS_FLAGS)0);
        }
        pnode = (OS_FLAG_NODE *)pnode->OSFlagNodeNext;  
    }
    do { OS_CPU_SR_Restore(cpu_sr);} while (0);
    if (sched == 1u) {
        OS_Sched();
    }
    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    flags_cur = pgrp->OSFlagFlags;
    do { OS_CPU_SR_Restore(cpu_sr);} while (0);
    *perr     = 0u;
    ;

    return (flags_cur);
}



















 


OS_FLAGS  OSFlagQuery (OS_FLAG_GRP  *pgrp,
                       INT8U        *perr)
{
    OS_FLAGS   flags;

    OS_CPU_SR  cpu_sr = 0u;




#line 1033 "Source\\os_flag.c"


    if (pgrp == (OS_FLAG_GRP *)0) {                
        *perr = 110u;
        return ((OS_FLAGS)0);
    }

    if (pgrp->OSFlagType != 5u) {  
        *perr = 1u;
        return ((OS_FLAGS)0);
    }
    do { cpu_sr = OS_CPU_SR_Save(1u << (8u - 4u));} while (0);
    flags = pgrp->OSFlagFlags;
    do { OS_CPU_SR_Restore(cpu_sr);} while (0);
    *perr = 0u;
    return (flags);                                
}






































 

static  void  OS_FlagBlock (OS_FLAG_GRP  *pgrp,
                            OS_FLAG_NODE *pnode,
                            OS_FLAGS      flags,
                            INT8U         wait_type,
                            INT32U        timeout)
{
    OS_FLAG_NODE  *pnode_next;
    INT8U          y;


    OSTCBCur->OSTCBStat      |= 0x20u;
    OSTCBCur->OSTCBStatPend   = 0u;
    OSTCBCur->OSTCBDly        = timeout;               

    OSTCBCur->OSTCBFlagNode   = pnode;                 

    pnode->OSFlagNodeFlags    = flags;                 
    pnode->OSFlagNodeWaitType = wait_type;             
    pnode->OSFlagNodeTCB      = (void *)OSTCBCur;      
    pnode->OSFlagNodeNext     = pgrp->OSFlagWaitList;  
    pnode->OSFlagNodePrev     = (void *)0;
    pnode->OSFlagNodeFlagGrp  = (void *)pgrp;          
    pnode_next                = (OS_FLAG_NODE *)pgrp->OSFlagWaitList;
    if (pnode_next != (void *)0) {                     
        pnode_next->OSFlagNodePrev = pnode;            
    }
    pgrp->OSFlagWaitList = (void *)pnode;

    y            =  OSTCBCur->OSTCBY;                  
    OSRdyTbl[y] &= (OS_PRIO)~OSTCBCur->OSTCBBitX;
    ;
    if (OSRdyTbl[y] == 0x00u) {
        OSRdyGrp &= (OS_PRIO)~OSTCBCur->OSTCBBitY;
    }
}















 

void  OS_FlagInit (void)
{
#line 1153 "Source\\os_flag.c"


    INT16U        ix;
    INT16U        ix_next;
    OS_FLAG_GRP  *pgrp1;
    OS_FLAG_GRP  *pgrp2;


    OS_MemClr((INT8U *)&OSFlagTbl[0], sizeof(OSFlagTbl));            
    for (ix = 0u; ix < (5u - 1u); ix++) {                  
        ix_next = ix + 1u;
        pgrp1 = &OSFlagTbl[ix];
        pgrp2 = &OSFlagTbl[ix_next];
        pgrp1->OSFlagType     = 0u;
        pgrp1->OSFlagWaitList = (void *)pgrp2;

        pgrp1->OSFlagName     = (INT8U *)(void *)"?";                

    }
    pgrp1                 = &OSFlagTbl[ix];
    pgrp1->OSFlagType     = 0u;
    pgrp1->OSFlagWaitList = (void *)0;

    pgrp1->OSFlagName     = (INT8U *)(void *)"?";                    

    OSFlagFreeList        = &OSFlagTbl[0];

}


























 

static  BOOLEAN  OS_FlagTaskRdy (OS_FLAG_NODE *pnode,
                                 OS_FLAGS      flags_rdy,
                                 INT8U         pend_stat)
{
    OS_TCB   *ptcb;
    BOOLEAN   sched;


    ptcb                 = (OS_TCB *)pnode->OSFlagNodeTCB;  
    ptcb->OSTCBDly       = 0u;
    ptcb->OSTCBFlagsRdy  = flags_rdy;
    ptcb->OSTCBStat     &= (INT8U)~(INT8U)0x20u;
    ptcb->OSTCBStatPend  = pend_stat;
    if (ptcb->OSTCBStat == 0x00u) {                   
        OSRdyGrp               |= ptcb->OSTCBBitY;          
        OSRdyTbl[ptcb->OSTCBY] |= ptcb->OSTCBBitX;
        ;
        sched                   = 1u;
    } else {
        sched                   = 0u;
    }
    OS_FlagUnlink(pnode);
    return (sched);
}





















 

void  OS_FlagUnlink (OS_FLAG_NODE *pnode)
{

    OS_TCB       *ptcb;

    OS_FLAG_GRP  *pgrp;
    OS_FLAG_NODE *pnode_prev;
    OS_FLAG_NODE *pnode_next;


    pnode_prev = (OS_FLAG_NODE *)pnode->OSFlagNodePrev;
    pnode_next = (OS_FLAG_NODE *)pnode->OSFlagNodeNext;
    if (pnode_prev == (OS_FLAG_NODE *)0) {                       
        pgrp                 = (OS_FLAG_GRP *)pnode->OSFlagNodeFlagGrp;
        pgrp->OSFlagWaitList = (void *)pnode_next;               
        if (pnode_next != (OS_FLAG_NODE *)0) {
            pnode_next->OSFlagNodePrev = (OS_FLAG_NODE *)0;      
        }
    } else {                                                     
        pnode_prev->OSFlagNodeNext = pnode_next;                 
        if (pnode_next != (OS_FLAG_NODE *)0) {                   
            pnode_next->OSFlagNodePrev = pnode_prev;             
        }
    }

    ptcb                = (OS_TCB *)pnode->OSFlagNodeTCB;
    ptcb->OSTCBFlagNode = (OS_FLAG_NODE *)0;

}
