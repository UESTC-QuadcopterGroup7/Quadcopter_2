#line 1 "UCOS_Source\\ucos_ii.c"














 







 

#line 1 ".\\UCOS_Source\\ucos_ii.h"














 






 












 







 

#line 1 ".\\UCOS_CFG\\app_cfg.h"



#line 46 ".\\UCOS_Source\\ucos_ii.h"
#line 1 ".\\UCOS_Port\\os_cfg.h"



#line 79 ".\\UCOS_Port\\os_cfg.h"

#line 47 ".\\UCOS_Source\\ucos_ii.h"
#line 1 ".\\UCOS_Port\\os_cpu.h"








 

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

#line 48 ".\\UCOS_Source\\ucos_ii.h"
#line 1 ".\\UCOS_Source\\os_trace.h"














 















 




#line 37 ".\\UCOS_Source\\os_trace.h"










 

#line 61 ".\\UCOS_Source\\os_trace.h"

#line 71 ".\\UCOS_Source\\os_trace.h"



















































































































































































































































































































































































































#line 49 ".\\UCOS_Source\\ucos_ii.h"





 





























#line 91 ".\\UCOS_Source\\ucos_ii.h"













 
#line 113 ".\\UCOS_Source\\ucos_ii.h"







 








 
#line 136 ".\\UCOS_Source\\ucos_ii.h"


                                             





 

























 











 









 









 









 










 












 









 


#line 258 ".\\UCOS_Source\\ucos_ii.h"

#line 269 ".\\UCOS_Source\\ucos_ii.h"














#line 297 ".\\UCOS_Source\\ucos_ii.h"

#line 304 ".\\UCOS_Source\\ucos_ii.h"

#line 315 ".\\UCOS_Source\\ucos_ii.h"



#line 324 ".\\UCOS_Source\\ucos_ii.h"



#line 341 ".\\UCOS_Source\\ucos_ii.h"














 

#line 364 ".\\UCOS_Source\\ucos_ii.h"





 


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







 

#line 684 ".\\UCOS_Source\\ucos_ii.h"





 

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








 

#line 850 ".\\UCOS_Source\\ucos_ii.h"






 




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









 


















 





 

#line 1491 ".\\UCOS_Source\\ucos_ii.h"






























 

#line 1529 ".\\UCOS_Source\\ucos_ii.h"


























 

#line 1567 ".\\UCOS_Source\\ucos_ii.h"














 

#line 1589 ".\\UCOS_Source\\ucos_ii.h"














 

#line 1615 ".\\UCOS_Source\\ucos_ii.h"






































 

#line 1661 ".\\UCOS_Source\\ucos_ii.h"






















 

#line 1691 ".\\UCOS_Source\\ucos_ii.h"



































#line 1733 ".\\UCOS_Source\\ucos_ii.h"

















#line 1757 ".\\UCOS_Source\\ucos_ii.h"





 





















 

#line 1793 ".\\UCOS_Source\\ucos_ii.h"

#line 1800 ".\\UCOS_Source\\ucos_ii.h"






#line 1812 ".\\UCOS_Source\\ucos_ii.h"
























 


























#line 1870 ".\\UCOS_Source\\ucos_ii.h"



































 

#line 1982 ".\\UCOS_Source\\ucos_ii.h"





#line 27 "UCOS_Source\\ucos_ii.c"


#line 1 ".\\UCOS_Source\\os_core.c"














 










 


















 

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






#line 134 ".\\UCOS_Source\\os_core.c"


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
    {};
    *pname = pevent->OSEventName;
    len    = OS_StrLen(*pname);
    {};
    *perr  = 0u;
    return (len);
}



























 


void  OSEventNameSet (OS_EVENT  *pevent,
                      INT8U     *pname,
                      INT8U     *perr)
{






#line 213 ".\\UCOS_Source\\os_core.c"


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
    {};
    pevent->OSEventName = pname;
    {};
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






#line 346 ".\\UCOS_Source\\os_core.c"


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
    {};
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
                 {};
                *pevents_rdy = (OS_EVENT *)0;            
                *perr        =  1u;
                 return (events_rdy_nbr);
        }
        pevents++;
        pevent = *pevents;
    }

    if ( events_rdy == 1u) {                        
       *pevents_rdy = (OS_EVENT *)0;                     
        {};
       *perr        =  0u;
        return (events_rdy_nbr);
    }

                                                         
    OSTCBCur->OSTCBStat     |= events_stat  |            
                               0x80u;            
    OSTCBCur->OSTCBStatPend  = 0u;
    OSTCBCur->OSTCBDly       = timeout;                  
    OS_EventTaskWaitMulti(pevents_pend);                 

    {};
    OS_Sched();                                          
    {};

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
                      {};
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

    {};

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


#line 620 ".\\UCOS_Source\\os_core.c"

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






    if (OSRunning == 1u) {
        {};
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

        {};
    }
}

















 

#line 763 ".\\UCOS_Source\\os_core.c"
















 


void  OSSchedLock (void)
{






    if (OSRunning == 1u) {                   
        {};
        if (OSIntNesting == 0u) {                 
            if (OSLockNesting < 255u) {           
                OSLockNesting++;                  
            }
        }
        {};
    }
}
















 


void  OSSchedUnlock (void)
{






    if (OSRunning == 1u) {                             
        {};
        if (OSIntNesting == 0u) {                           
            if (OSLockNesting > 0u) {                       
                OSLockNesting--;                            
                if (OSLockNesting == 0u) {                  
                    {};
                    OS_Sched();                             
                } else {
                    {};
                }
            } else {
                {};
            }
        } else {
            {};
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






    OSTimeDly(2u);                                
    {};
    OSIdleCtr    = 0uL;                           
    {};
    OSTimeDly(100u / 10u);            
    {};
    OSIdleCtrMax = OSIdleCtr;                     
    OSStatRdy    = 1u;
    {};
}















 

void  OSTimeTick (void)
{
    OS_TCB    *ptcb;

    BOOLEAN    step;








    OSTimeTickHook();                                       


    {};                                    
    OSTime++;
    ;
    {};

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
            {};
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
            {};
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
#line 1110 ".\\UCOS_Source\\os_core.c"

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
#line 1373 ".\\UCOS_Source\\os_core.c"
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



#line 1484 ".\\UCOS_Source\\os_core.c"
    (void)OSTaskCreateExt(OS_TaskIdle,
                          (void *)0,                                  
                          &OSTaskIdleStk[0],                          
                          (63u),                          
                          65535u,
                          &OSTaskIdleStk[128u - 1u], 
                          128u,
                          (void *)0,                                  
                          0x0001u | 0x0002u); 
#line 1507 ".\\UCOS_Source\\os_core.c"


    OSTaskNameSet((63u), (INT8U *)(void *)"uC/OS-II Idle", &err);

}













 


static  void  OS_InitTaskStat (void)
{

    INT8U  err;



#line 1547 ".\\UCOS_Source\\os_core.c"
    (void)OSTaskCreateExt(OS_TaskStat,
                          (void *)0,                                    
                          &OSTaskStatStk[0],                            
                          (63u - 1u),                            
                          65534u,
                          &OSTaskStatStk[128u - 1u],   
                          128u,
                          (void *)0,                                    
                          0x0001u | 0x0002u);   
#line 1570 ".\\UCOS_Source\\os_core.c"


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






    {};
    if (OSIntNesting == 0u) {                           
        if (OSLockNesting == 0u) {                      
            OS_SchedNew();
            OSTCBHighRdy = OSTCBPrioTbl[OSPrioHighRdy];
            if (OSPrioHighRdy != OSPrioCur) {           

                OSTCBHighRdy->OSTCBCtxSwCtr++;          

                OSCtxSwCtr++;                           







                OS_TASK_SW();                           
            }
        }
    }
    {};
}
















 

static  void  OS_SchedNew (void)
{

    INT8U   y;


    y             = OSUnMapTbl[OSRdyGrp];
    OSPrioHighRdy = (INT8U)((y << 3u) + OSUnMapTbl[OSRdyTbl[y]]);
#line 1776 ".\\UCOS_Source\\os_core.c"
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




    (void)p_arg;                                  
    for (;;) {
        {};
        OSIdleCtr++;
        {};
        OSTaskIdleHook();                         
    }
}
























 


void  OS_TaskStat (void *p_arg)
{
    INT8S  usage;






    p_arg = p_arg;                                
    while (OSStatRdy == 0u) {
        OSTimeDly(2u * 100u / 10u);   
    }
    OSIdleCtrMax /= 100uL;
    if (OSIdleCtrMax == 0uL) {
        OSCPUUsage = 0u;

        (void)OSTaskSuspend(0xFFu);





    }
    {};
    OSIdleCtr = OSIdleCtrMax * 100uL;             
    {};
    for (;;) {
        OSTimeDly(1);                             

        {};
        OSIdleCtr = 0uL;                         
        {};

        OSTimeDly(100u / 10u);        

        {};
        OSIdleCtrRun = OSIdleCtr;                 
        {};

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




                    ptcb->OSTCBStkBase = ptcb->OSTCBStkBottom - ptcb->OSTCBStkSize;

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




    INT8U      i;
#line 2042 ".\\UCOS_Source\\os_core.c"


    {};
    ptcb = OSTCBFreeList;                                   
    if (ptcb != (OS_TCB *)0) {
        OSTCBFreeList            = ptcb->OSTCBNext;         
        {};
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
#line 2068 ".\\UCOS_Source\\os_core.c"


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

        {};
        OSTCBPrioTbl[prio] = ptcb;
        {};

        OSTaskCreateHook(ptcb);                             

#line 2134 ".\\UCOS_Source\\os_core.c"

        {};
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
        {};
        return (0u);
    }
    {};
    return (66u);
}

#line 31 "UCOS_Source\\ucos_ii.c"
#line 1 ".\\UCOS_Source\\os_flag.c"














 










 















 

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






#line 121 ".\\UCOS_Source\\os_flag.c"


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
    {};
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
             {};
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
             {};
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
             {};
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
             {};
             break;


        default:
             {};
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






#line 242 ".\\UCOS_Source\\os_flag.c"

#line 250 ".\\UCOS_Source\\os_flag.c"

    if (OSIntNesting > 0u) {                         
        *perr = 16u;                   
        return ((OS_FLAG_GRP *)0);
    }
    {};
    pgrp = OSFlagFreeList;                           
    if (pgrp != (OS_FLAG_GRP *)0) {                  
                                                     
        OSFlagFreeList       = (OS_FLAG_GRP *)OSFlagFreeList->OSFlagWaitList;
        pgrp->OSFlagType     = 5u;   
        pgrp->OSFlagFlags    = flags;                
        pgrp->OSFlagWaitList = (void *)0;            

        pgrp->OSFlagName     = (INT8U *)(void *)"?";

        ;
        {};
        *perr                = 0u;
    } else {
        {};
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





#line 336 ".\\UCOS_Source\\os_flag.c"

#line 344 ".\\UCOS_Source\\os_flag.c"


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
    {};
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
                 {};
                 *perr                = 0u;
                 pgrp_return          = (OS_FLAG_GRP *)0;   
             } else {
                 {};
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
             {};
             if (tasks_waiting == 1u) {                
                 OS_Sched();                                
             }
             *perr = 0u;
             pgrp_return          = (OS_FLAG_GRP *)0;       
             break;

        default:
             {};
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






#line 466 ".\\UCOS_Source\\os_flag.c"


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
    {};
    if (pgrp->OSFlagType != 5u) {
        {};
        *perr = 1u;
        return (0u);
    }
    *pname = pgrp->OSFlagName;
    len    = OS_StrLen(*pname);
    {};
    *perr  = 0u;
    return (len);
}
























 


void  OSFlagNameSet (OS_FLAG_GRP  *pgrp,
                     INT8U        *pname,
                     INT8U        *perr)
{






#line 536 ".\\UCOS_Source\\os_flag.c"


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
    {};
    if (pgrp->OSFlagType != 5u) {
        {};
        *perr = 1u;
        return;
    }
    pgrp->OSFlagName = pname;
    {};
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





#line 642 ".\\UCOS_Source\\os_flag.c"


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

    {};
    switch (wait_type) {
        case 2u:                          
             flags_rdy = (OS_FLAGS)(pgrp->OSFlagFlags & flags);    
             if (flags_rdy == flags) {                      
                 if (consume == 1u) {                  
                     pgrp->OSFlagFlags &= (OS_FLAGS)~flags_rdy;    
                 }
                 OSTCBCur->OSTCBFlagsRdy = flags_rdy;       
                 {};                        
                 *perr                   = 0u;
                 ;
                 return (flags_rdy);
             } else {                                       
                 OS_FlagBlock(pgrp, &node, flags, wait_type, timeout);
                 {};
             }
             break;

        case 3u:
             flags_rdy = (OS_FLAGS)(pgrp->OSFlagFlags & flags);     
             if (flags_rdy != (OS_FLAGS)0) {                
                 if (consume == 1u) {                  
                     pgrp->OSFlagFlags &= (OS_FLAGS)~flags_rdy;     
                 }
                 OSTCBCur->OSTCBFlagsRdy = flags_rdy;       
                 {};                        
                 *perr                   = 0u;
                 ;
                 return (flags_rdy);
             } else {                                       
                 OS_FlagBlock(pgrp, &node, flags, wait_type, timeout);
                 {};
             }
             break;


        case 0u:                          
             flags_rdy = (OS_FLAGS)~pgrp->OSFlagFlags & flags;     
             if (flags_rdy == flags) {                      
                 if (consume == 1u) {                  
                     pgrp->OSFlagFlags |= flags_rdy;        
                 }
                 OSTCBCur->OSTCBFlagsRdy = flags_rdy;       
                 {};                        
                 *perr                   = 0u;
                 ;
                 return (flags_rdy);
             } else {                                       
                 OS_FlagBlock(pgrp, &node, flags, wait_type, timeout);
                 {};
             }
             break;

        case 1u:
             flags_rdy = (OS_FLAGS)~pgrp->OSFlagFlags & flags;    
             if (flags_rdy != (OS_FLAGS)0) {                
                 if (consume == 1u) {                  
                     pgrp->OSFlagFlags |= flags_rdy;        
                 }
                 OSTCBCur->OSTCBFlagsRdy = flags_rdy;       
                 {};                        
                 *perr                   = 0u;
                 ;
                 return (flags_rdy);
             } else {                                       
                 OS_FlagBlock(pgrp, &node, flags, wait_type, timeout);
                 {};
             }
             break;


        default:
             {};
             flags_rdy = (OS_FLAGS)0;
             *perr      = 111u;
             ;
             return (flags_rdy);
    }

    OS_Sched();                                             
    {};
    if (OSTCBCur->OSTCBStatPend != 0u) {       
        pend_stat                = OSTCBCur->OSTCBStatPend;
        OSTCBCur->OSTCBStatPend  = 0u;
        OS_FlagUnlink(&node);
        OSTCBCur->OSTCBStat      = 0x00u;             
        {};
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
                 {};
                 *perr = 111u;
                 ;
                 return ((OS_FLAGS)0);
        }
    }
    {};
    *perr = 0u;                                    
    ;
    return (flags_rdy);
}















 

OS_FLAGS  OSFlagPendGetFlagsRdy (void)
{
    OS_FLAGS      flags;






    {};
    flags = OSTCBCur->OSTCBFlagsRdy;
    {};
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





#line 898 ".\\UCOS_Source\\os_flag.c"


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

    {};
    switch (opt) {
        case 0u:
             pgrp->OSFlagFlags &= (OS_FLAGS)~flags;   
             break;

        case 1u:
             pgrp->OSFlagFlags |=  flags;             
             break;

        default:
             {};                      
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
                 {};
                 *perr = 111u;
                 ;
                 return ((OS_FLAGS)0);
        }
        pnode = (OS_FLAG_NODE *)pnode->OSFlagNodeNext;  
    }
    {};
    if (sched == 1u) {
        OS_Sched();
    }
    {};
    flags_cur = pgrp->OSFlagFlags;
    {};
    *perr     = 0u;
    ;

    return (flags_cur);
}



















 


OS_FLAGS  OSFlagQuery (OS_FLAG_GRP  *pgrp,
                       INT8U        *perr)
{
    OS_FLAGS   flags;






#line 1033 ".\\UCOS_Source\\os_flag.c"


    if (pgrp == (OS_FLAG_GRP *)0) {                
        *perr = 110u;
        return ((OS_FLAGS)0);
    }

    if (pgrp->OSFlagType != 5u) {  
        *perr = 1u;
        return ((OS_FLAGS)0);
    }
    {};
    flags = pgrp->OSFlagFlags;
    {};
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
#line 1153 ".\\UCOS_Source\\os_flag.c"


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
#line 32 "UCOS_Source\\ucos_ii.c"
#line 1 ".\\UCOS_Source\\os_mbox.c"














 










 


























 


void  *OSMboxAccept (OS_EVENT *pevent)
{
    void      *pmsg;







    if (pevent == (OS_EVENT *)0) {                         
        return ((void *)0);
    }

    if (pevent->OSEventType != 1u) {       
        return ((void *)0);
    }
    {};
    pmsg               = pevent->OSEventPtr;
    pevent->OSEventPtr = (void *)0;                        
    {};
    return (pmsg);                                         
}

















 

OS_EVENT  *OSMboxCreate (void *pmsg)
{
    OS_EVENT  *pevent;






#line 113 ".\\UCOS_Source\\os_mbox.c"

    if (OSIntNesting > 0u) {                      
        return ((OS_EVENT *)0);                   
    }
    {};
    pevent = OSEventFreeList;                     
    if (OSEventFreeList != (OS_EVENT *)0) {       
        OSEventFreeList = (OS_EVENT *)OSEventFreeList->OSEventPtr;
    }
    {};
    if (pevent != (OS_EVENT *)0) {
        pevent->OSEventType    = 1u;
        pevent->OSEventCnt     = 0u;
        pevent->OSEventPtr     = pmsg;            

        pevent->OSEventName    = (INT8U *)(void *)"?";

        OS_EventWaitListInit(pevent);

        ;
    }
    return (pevent);                              
}








































 


OS_EVENT  *OSMboxDel (OS_EVENT  *pevent,
                      INT8U      opt,
                      INT8U     *perr)
{
    BOOLEAN    tasks_waiting;
    OS_EVENT  *pevent_return;






#line 197 ".\\UCOS_Source\\os_mbox.c"

#line 205 ".\\UCOS_Source\\os_mbox.c"


    if (pevent == (OS_EVENT *)0) {                          
        *perr = 4u;
        return (pevent);
    }


    ;

    if (pevent->OSEventType != 1u) {        
        *perr = 1u;
        ;
        return (pevent);
    }
    if (OSIntNesting > 0u) {                                
        *perr = 15u;                             
        ;
        return (pevent);
    }
    {};
    if (pevent->OSEventGrp != 0u) {                         
        tasks_waiting = 1u;                            
    } else {
        tasks_waiting = 0u;                           
    }
    switch (opt) {
        case 0u:                                
             if (tasks_waiting == 0u) {

                 pevent->OSEventName = (INT8U *)(void *)"?";

                 pevent->OSEventType = 0u;
                 pevent->OSEventPtr  = OSEventFreeList;     
                 pevent->OSEventCnt  = 0u;
                 OSEventFreeList     = pevent;              
                 {};
                 *perr               = 0u;
                 pevent_return       = (OS_EVENT *)0;       
             } else {
                 {};
                 *perr               = 73u;
                 pevent_return       = pevent;
             }
             break;

        case 1u:                                 
             while (pevent->OSEventGrp != 0u) {             
                 (void)OS_EventTaskRdy(pevent, (void *)0, 0x02u, 2u);
             }

             pevent->OSEventName    = (INT8U *)(void *)"?";

             pevent->OSEventType    = 0u;
             pevent->OSEventPtr     = OSEventFreeList;      
             pevent->OSEventCnt     = 0u;
             OSEventFreeList        = pevent;               
             {};
             if (tasks_waiting == 1u) {                
                 OS_Sched();                                
             }
             *perr         = 0u;
             pevent_return = (OS_EVENT *)0;                 
             break;

        default:
             {};
             *perr         = 7u;
             pevent_return = pevent;
             break;
    }

    ;

    return (pevent_return);
}


































 

void  *OSMboxPend (OS_EVENT  *pevent,
                   INT32U     timeout,
                   INT8U     *perr)
{
    void      *pmsg;





#line 333 ".\\UCOS_Source\\os_mbox.c"


    if (pevent == (OS_EVENT *)0) {                     
        *perr = 4u;
        return ((void *)0);
    }


    ;

    if (pevent->OSEventType != 1u) {   
        *perr = 1u;
        ;
        return ((void *)0);
    }
    if (OSIntNesting > 0u) {                           
        *perr = 2u;                       
        ;
        return ((void *)0);
    }
    if (OSLockNesting > 0u) {                          
        *perr = 13u;                    
        ;
        return ((void *)0);
    }
    {};
    pmsg = pevent->OSEventPtr;
    if (pmsg != (void *)0) {                           
        pevent->OSEventPtr = (void *)0;                
        {};
        *perr = 0u;
        ;
        return (pmsg);                                 
    }
    OSTCBCur->OSTCBStat     |= 0x02u;           
    OSTCBCur->OSTCBStatPend  = 0u;
    OSTCBCur->OSTCBDly       = timeout;                
    OS_EventTaskWait(pevent);                          
    {};
    OS_Sched();                                        
    {};
    switch (OSTCBCur->OSTCBStatPend) {                 
        case 0u:
             pmsg =  OSTCBCur->OSTCBMsg;
            *perr =  0u;
             break;

        case 2u:
             pmsg = (void *)0;
            *perr =  14u;                
             break;

        case 1u:
        default:
             OS_EventTaskRemove(OSTCBCur, pevent);
             pmsg = (void *)0;
            *perr =  10u;                   
             break;
    }
    OSTCBCur->OSTCBStat          =  0x00u;       
    OSTCBCur->OSTCBStatPend      =  0u;   
    OSTCBCur->OSTCBEventPtr      = (OS_EVENT  *)0;     

    OSTCBCur->OSTCBEventMultiPtr = (OS_EVENT **)0;
    OSTCBCur->OSTCBEventMultiRdy = (OS_EVENT  *)0;

    OSTCBCur->OSTCBMsg           = (void      *)0;     
    {};
    ;

    return (pmsg);                                     
}
































 


INT8U  OSMboxPendAbort (OS_EVENT  *pevent,
                        INT8U      opt,
                        INT8U     *perr)
{
    INT8U      nbr_tasks;






#line 457 ".\\UCOS_Source\\os_mbox.c"


    if (pevent == (OS_EVENT *)0) {                          
        *perr = 4u;
        return (0u);
    }

    if (pevent->OSEventType != 1u) {        
        *perr = 1u;
        return (0u);
    }
    {};
    if (pevent->OSEventGrp != 0u) {                         
        nbr_tasks = 0u;
        switch (opt) {
            case 1u:                     
                 while (pevent->OSEventGrp != 0u) {         
                     (void)OS_EventTaskRdy(pevent, (void *)0, 0x02u, 2u);
                     nbr_tasks++;
                 }
                 break;

            case 0u:
            default:                                        
                 (void)OS_EventTaskRdy(pevent, (void *)0, 0x02u, 2u);
                 nbr_tasks++;
                 break;
        }
        {};
        OS_Sched();                                         
        *perr = 14u;
        return (nbr_tasks);
    }
    {};
    *perr = 0u;
    return (0u);                                            
}























 


INT8U  OSMboxPost (OS_EVENT  *pevent,
                   void      *pmsg)
{







    if (pevent == (OS_EVENT *)0) {                     
        return (4u);
    }
    if (pmsg == (void *)0) {                           
        return (3u);
    }


    ;

    if (pevent->OSEventType != 1u) {   
        ;
        return (1u);
    }
    {};
    if (pevent->OSEventGrp != 0u) {                    
                                                       
        (void)OS_EventTaskRdy(pevent, pmsg, 0x02u, 0u);
        {};
        OS_Sched();                                    
        ;
        return (0u);
    }
    if (pevent->OSEventPtr != (void *)0) {             
        {};
        ;
        return (20u);
    }
    pevent->OSEventPtr = pmsg;                         
    {};
    ;
    return (0u);
}

































 


INT8U  OSMboxPostOpt (OS_EVENT  *pevent,
                      void      *pmsg,
                      INT8U      opt)
{







    if (pevent == (OS_EVENT *)0) {                     
        return (4u);
    }
    if (pmsg == (void *)0) {                           
        return (3u);
    }


    ;

    if (pevent->OSEventType != 1u) {   
        ;
        return (1u);
    }
    {};
    if (pevent->OSEventGrp != 0u) {                    
        if ((opt & 0x01u) != 0x00u) {  
            while (pevent->OSEventGrp != 0u) {         
                (void)OS_EventTaskRdy(pevent, pmsg, 0x02u, 0u);
            }
        } else {                                       
            (void)OS_EventTaskRdy(pevent, pmsg, 0x02u, 0u);
        }
        {};
        if ((opt & 0x04u) == 0u) {      
            OS_Sched();                                
        }
        ;
        return (0u);
    }
    if (pevent->OSEventPtr != (void *)0) {             
        {};
        ;
        return (20u);
    }
    pevent->OSEventPtr = pmsg;                         
    {};
    ;
    return (0u);
}



















 


INT8U  OSMboxQuery (OS_EVENT      *pevent,
                    OS_MBOX_DATA  *p_mbox_data)
{
    INT8U       i;
    OS_PRIO    *psrc;
    OS_PRIO    *pdest;







    if (pevent == (OS_EVENT *)0) {                          
        return (4u);
    }
    if (p_mbox_data == (OS_MBOX_DATA *)0) {                 
        return (9u);
    }

    if (pevent->OSEventType != 1u) {        
        return (1u);
    }
    {};
    p_mbox_data->OSEventGrp = pevent->OSEventGrp;           
    psrc                    = &pevent->OSEventTbl[0];
    pdest                   = &p_mbox_data->OSEventTbl[0];
    for (i = 0u; i < ((63u) / 8u + 1u); i++) {
        *pdest++ = *psrc++;
    }
    p_mbox_data->OSMsg = pevent->OSEventPtr;                
    {};
    return (0u);
}
#line 33 "UCOS_Source\\ucos_ii.c"
#line 1 ".\\UCOS_Source\\os_mem.c"














 










 









































 

OS_MEM  *OSMemCreate (void   *addr,
                      INT32U  nblks,
                      INT32U  blksize,
                      INT8U  *perr)
{
    OS_MEM    *pmem;
    INT8U     *pblk;
    void     **plink;
    INT32U     loops;
    INT32U     i;






#line 92 ".\\UCOS_Source\\os_mem.c"

#line 100 ".\\UCOS_Source\\os_mem.c"


    if (addr == (void *)0) {                           
        *perr = 98u;
        return ((OS_MEM *)0);
    }
    if (((INT32U)addr & (sizeof(void *) - 1u)) != 0u){   
        *perr = 98u;
        return ((OS_MEM *)0);
    }
    if (nblks < 2u) {                                  
        *perr = 91u;
        return ((OS_MEM *)0);
    }
    if (blksize < sizeof(void *)) {                    
        *perr = 92u;
        return ((OS_MEM *)0);
    }

    {};
    pmem = OSMemFreeList;                              
    if (OSMemFreeList != (OS_MEM *)0) {                
        OSMemFreeList = (OS_MEM *)OSMemFreeList->OSMemFreeList;
    }
    {};
    if (pmem == (OS_MEM *)0) {                         
        *perr = 90u;
        return ((OS_MEM *)0);
    }
    plink = (void **)addr;                             
    pblk  = (INT8U *)addr;
    loops  = nblks - 1u;
    for (i = 0u; i < loops; i++) {
        pblk +=  blksize;                              
       *plink = (void  *)pblk;                         
        plink = (void **)pblk;                         
    }
    *plink              = (void *)0;                   
    pmem->OSMemAddr     = addr;                        
    pmem->OSMemFreeList = addr;                        
    pmem->OSMemNFree    = nblks;                       
    pmem->OSMemNBlks    = nblks;
    pmem->OSMemBlkSize  = blksize;                     

    ;

    *perr               = 0u;
    return (pmem);
}




















 

void  *OSMemGet (OS_MEM  *pmem,
                 INT8U   *perr)
{
    void      *pblk;





#line 186 ".\\UCOS_Source\\os_mem.c"


    if (pmem == (OS_MEM *)0) {                         
        *perr = 96u;
        return ((void *)0);
    }


    ;

    {};
    if (pmem->OSMemNFree > 0u) {                       
        pblk                = pmem->OSMemFreeList;     
        pmem->OSMemFreeList = *(void **)pblk;          
        pmem->OSMemNFree--;                            
        {};
        *perr = 0u;                           
        ;
        return (pblk);                                 
    }
    {};
    *perr = 93u;                   
    ;
    return ((void *)0);                                
}





















 


INT8U  OSMemNameGet (OS_MEM   *pmem,
                     INT8U   **pname,
                     INT8U    *perr)
{
    INT8U      len;






#line 252 ".\\UCOS_Source\\os_mem.c"


    if (pmem == (OS_MEM *)0) {                    
        *perr = 96u;
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
    {};
    *pname = pmem->OSMemName;
    len    = OS_StrLen(*pname);
    {};
    *perr  = 0u;
    return (len);
}























 


void  OSMemNameSet (OS_MEM  *pmem,
                    INT8U   *pname,
                    INT8U   *perr)
{






#line 316 ".\\UCOS_Source\\os_mem.c"


    if (pmem == (OS_MEM *)0) {                    
        *perr = 96u;
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
    {};
    pmem->OSMemName = pname;
    {};
    ;
    *perr           = 0u;
}



















 

INT8U  OSMemPut (OS_MEM  *pmem,
                 void    *pblk)
{






    if (pmem == (OS_MEM *)0) {                    
        return (96u);
    }
    if (pblk == (void *)0) {                      
        return (95u);
    }


    ;

    {};
    if (pmem->OSMemNFree >= pmem->OSMemNBlks) {   
        {};
        ;
        return (94u);
    }
    *(void **)pblk      = pmem->OSMemFreeList;    
    pmem->OSMemFreeList = pblk;
    pmem->OSMemNFree++;                           
    {};
    ;
    return (0u);                         
}


















 


INT8U  OSMemQuery (OS_MEM       *pmem,
                   OS_MEM_DATA  *p_mem_data)
{







    if (pmem == (OS_MEM *)0) {                    
        return (96u);
    }
    if (p_mem_data == (OS_MEM_DATA *)0) {         
        return (97u);
    }

    {};
    p_mem_data->OSAddr     = pmem->OSMemAddr;
    p_mem_data->OSFreeList = pmem->OSMemFreeList;
    p_mem_data->OSBlkSize  = pmem->OSMemBlkSize;
    p_mem_data->OSNBlks    = pmem->OSMemNBlks;
    p_mem_data->OSNFree    = pmem->OSMemNFree;
    {};
    p_mem_data->OSNUsed    = p_mem_data->OSNBlks - p_mem_data->OSNFree;
    return (0u);
}
















 

void  OS_MemInit (void)
{
#line 465 ".\\UCOS_Source\\os_mem.c"


    OS_MEM  *pmem;
    INT16U   i;


    OS_MemClr((INT8U *)&OSMemTbl[0], sizeof(OSMemTbl));    
    for (i = 0u; i < (5u - 1u); i++) {        
        pmem                = &OSMemTbl[i];                
        pmem->OSMemFreeList = (void *)&OSMemTbl[i + 1u];   

        pmem->OSMemName  = (INT8U *)(void *)"?";

    }
    pmem                = &OSMemTbl[i];
    pmem->OSMemFreeList = (void *)0;                       

    pmem->OSMemName = (INT8U *)(void *)"?";


    OSMemFreeList   = &OSMemTbl[0];                        

}
#line 34 "UCOS_Source\\ucos_ii.c"
#line 1 ".\\UCOS_Source\\os_mutex.c"














 










 
















 










 

static  void  OSMutex_RdyAtPrio(OS_TCB *ptcb, INT8U prio);

































 


BOOLEAN  OSMutexAccept (OS_EVENT  *pevent,
                        INT8U     *perr)
{
    INT8U      pcp;                                     






#line 109 ".\\UCOS_Source\\os_mutex.c"


    if (pevent == (OS_EVENT *)0) {                      
        *perr = 4u;
        return (0u);
    }

    if (pevent->OSEventType != 4u) {   
        *perr = 1u;
        return (0u);
    }
    if (OSIntNesting > 0u) {                            
        *perr = 2u;
        return (0u);
    }
    {};                                
    pcp = (INT8U)(pevent->OSEventCnt >> 8u);            
    if ((pevent->OSEventCnt & ((INT16U)0x00FFu)) == ((INT16U)0x00FFu)) {
        pevent->OSEventCnt &= ((INT16U)0xFF00u);    
        pevent->OSEventCnt |= (INT16U)OSTCBCur->OSTCBPrio;   
        pevent->OSEventPtr  = (void *)OSTCBCur;         
        if ((pcp != 0xFFu) &&
            (OSTCBCur->OSTCBPrio <= pcp)) {             
             {};                        
            *perr = 120u;
        } else {
             {};
            *perr = 0u;
        }
        return (1u);
    }
    {};
    *perr = 0u;
    return (0u);
}









































 

OS_EVENT  *OSMutexCreate (INT8U   prio,
                          INT8U  *perr)
{
    OS_EVENT  *pevent;






#line 203 ".\\UCOS_Source\\os_mutex.c"

#line 211 ".\\UCOS_Source\\os_mutex.c"


    if (prio != 0xFFu) {
        if (prio >= 63u) {                       
           *perr = 42u;
            return ((OS_EVENT *)0);
        }
    }

    if (OSIntNesting > 0u) {                                
        *perr = 16u;                          
        return ((OS_EVENT *)0);
    }
    {};
    if (prio != 0xFFu) {
        if (OSTCBPrioTbl[prio] != (OS_TCB *)0) {            
            {};                             
           *perr = 40u;                       
            return ((OS_EVENT *)0);
        }
        OSTCBPrioTbl[prio] = ((OS_TCB *)1);               
    }

    pevent = OSEventFreeList;                               
    if (pevent == (OS_EVENT *)0) {                          
        if (prio != 0xFFu) {
            OSTCBPrioTbl[prio] = (OS_TCB *)0;               
        }
        {};
       *perr = 4u;                          
        return (pevent);
    }
    OSEventFreeList     = (OS_EVENT *)OSEventFreeList->OSEventPtr;  
    {};
    pevent->OSEventType = 4u;
    pevent->OSEventCnt  = (INT16U)((INT16U)prio << 8u) | ((INT16U)0x00FFu);  
    pevent->OSEventPtr  = (void *)0;                        

    pevent->OSEventName = (INT8U *)(void *)"?";

    OS_EventWaitListInit(pevent);
    ;
   *perr = 0u;
    return (pevent);
}










































 


OS_EVENT  *OSMutexDel (OS_EVENT  *pevent,
                       INT8U      opt,
                       INT8U     *perr)
{
    BOOLEAN    tasks_waiting;
    OS_EVENT  *pevent_return;
    INT8U      pcp;                                         
    INT8U      prio;
    OS_TCB    *ptcb;





#line 321 ".\\UCOS_Source\\os_mutex.c"

#line 329 ".\\UCOS_Source\\os_mutex.c"


    if (pevent == (OS_EVENT *)0) {                          
        *perr = 4u;
        return (pevent);
    }


    ;

    if (pevent->OSEventType != 4u) {       
        *perr = 1u;
        ;
        return (pevent);
    }
    if (OSIntNesting > 0u) {                                
        *perr = 15u;                             
        ;
        return (pevent);
    }
    {};
    if (pevent->OSEventGrp != 0u) {                         
        tasks_waiting = 1u;                            
    } else {
        tasks_waiting = 0u;                           
    }
    switch (opt) {
        case 0u:                                
             if (tasks_waiting == 0u) {

                 pevent->OSEventName   = (INT8U *)(void *)"?";

                 pcp                   = (INT8U)(pevent->OSEventCnt >> 8u);
                 if (pcp != 0xFFu) {
                     OSTCBPrioTbl[pcp] = (OS_TCB *)0;       
                 }
                 pevent->OSEventType   = 0u;
                 pevent->OSEventPtr    = OSEventFreeList;   
                 pevent->OSEventCnt    = 0u;
                 OSEventFreeList       = pevent;
                 {};
                 *perr                 = 0u;
                 pevent_return         = (OS_EVENT *)0;     
             } else {
                 {};
                 *perr                 = 73u;
                 pevent_return         = pevent;
             }
             break;

        case 1u:                                 
             pcp  = (INT8U)(pevent->OSEventCnt >> 8u);                        
             if (pcp != 0xFFu) {
                 prio = (INT8U)(pevent->OSEventCnt & ((INT16U)0x00FFu));  
                 ptcb = (OS_TCB *)pevent->OSEventPtr;
                 if (ptcb != (OS_TCB *)0) {                 
                     if (ptcb->OSTCBPrio == pcp) {          
                         ;
                         OSMutex_RdyAtPrio(ptcb, prio);     
                     }
                 }
             }
             while (pevent->OSEventGrp != 0u) {             
                 (void)OS_EventTaskRdy(pevent, (void *)0, 0x10u, 2u);
             }

             pevent->OSEventName   = (INT8U *)(void *)"?";

             pcp                   = (INT8U)(pevent->OSEventCnt >> 8u);
             if (pcp != 0xFFu) {
                 OSTCBPrioTbl[pcp] = (OS_TCB *)0;           
             }
             pevent->OSEventType   = 0u;
             pevent->OSEventPtr    = OSEventFreeList;       
             pevent->OSEventCnt    = 0u;
             OSEventFreeList       = pevent;                
             {};
             if (tasks_waiting == 1u) {                
                 OS_Sched();                                
             }
             *perr         = 0u;
             pevent_return = (OS_EVENT *)0;                 
             break;

        default:
             {};
             *perr         = 7u;
             pevent_return = pevent;
             break;
    }

    ;

    return (pevent_return);
}









































 

void  OSMutexPend (OS_EVENT  *pevent,
                   INT32U     timeout,
                   INT8U     *perr)
{
    INT8U      pcp;                                         
    INT8U      mprio;                                       
    BOOLEAN    rdy;                                         
    OS_TCB    *ptcb;
    OS_EVENT  *pevent2;
    INT8U      y;





#line 488 ".\\UCOS_Source\\os_mutex.c"


    if (pevent == (OS_EVENT *)0) {                          
        *perr = 4u;
        return;
    }


    ;

    if (pevent->OSEventType != 4u) {       
        *perr = 1u;
        ;
        return;
    }
    if (OSIntNesting > 0u) {                                
        *perr = 2u;                            
        ;
        return;
    }
    if (OSLockNesting > 0u) {                               
        *perr = 13u;                         
        ;
        return;
    }

    {};
    pcp = (INT8U)(pevent->OSEventCnt >> 8u);                
                                                            
    if ((INT8U)(pevent->OSEventCnt & ((INT16U)0x00FFu)) == ((INT16U)0x00FFu)) {
        pevent->OSEventCnt &= ((INT16U)0xFF00u);        
        pevent->OSEventCnt |= (INT16U)OSTCBCur->OSTCBPrio;  
        pevent->OSEventPtr  = (void *)OSTCBCur;             
        if ((pcp != 0xFFu) &&
            (OSTCBCur->OSTCBPrio <= pcp)) {                 
             {};                            
            *perr = 120u;
        } else {
             {};
            *perr = 0u;
        }
        ;
        return;
    }
    if (pcp != 0xFFu) {
        mprio = (INT8U)(pevent->OSEventCnt & ((INT16U)0x00FFu));  
        ptcb  = (OS_TCB *)(pevent->OSEventPtr);                    
        if (ptcb->OSTCBPrio > pcp) {                               
            if (mprio > OSTCBCur->OSTCBPrio) {
                y = ptcb->OSTCBY;
                if ((OSRdyTbl[y] & ptcb->OSTCBBitX) != 0u) {       
                    OSRdyTbl[y] &= (OS_PRIO)~ptcb->OSTCBBitX;      
                    if (OSRdyTbl[y] == 0u) {                       
                        OSRdyGrp &= (OS_PRIO)~ptcb->OSTCBBitY;
                    }
                    rdy = 1u;
                } else {
                    pevent2 = ptcb->OSTCBEventPtr;
                    if (pevent2 != (OS_EVENT *)0) {                
                        y = ptcb->OSTCBY;
                        pevent2->OSEventTbl[y] &= (OS_PRIO)~ptcb->OSTCBBitX;
                        if (pevent2->OSEventTbl[y] == 0u) {
                            pevent2->OSEventGrp &= (OS_PRIO)~ptcb->OSTCBBitY;
                        }
                    }
                    rdy = 0u;                         
                }
                ptcb->OSTCBPrio = pcp;                      

                ;


                ptcb->OSTCBY    = (INT8U)( ptcb->OSTCBPrio >> 3u);
                ptcb->OSTCBX    = (INT8U)( ptcb->OSTCBPrio & 0x07u);




                ptcb->OSTCBBitY = (OS_PRIO)(1uL << ptcb->OSTCBY);
                ptcb->OSTCBBitX = (OS_PRIO)(1uL << ptcb->OSTCBX);

                if (rdy == 1u) {                       
                    OSRdyGrp               |= ptcb->OSTCBBitY;  
                    OSRdyTbl[ptcb->OSTCBY] |= ptcb->OSTCBBitX;
                } else {
                    pevent2 = ptcb->OSTCBEventPtr;
                    if (pevent2 != (OS_EVENT *)0) {         
                        pevent2->OSEventGrp               |= ptcb->OSTCBBitY;
                        pevent2->OSEventTbl[ptcb->OSTCBY] |= ptcb->OSTCBBitX;
                    }
                }
                OSTCBPrioTbl[pcp] = ptcb;
            }
        }
    }
    OSTCBCur->OSTCBStat     |= 0x10u;          
    OSTCBCur->OSTCBStatPend  = 0u;
    OSTCBCur->OSTCBDly       = timeout;                
    OS_EventTaskWait(pevent);                          
    {};
    OS_Sched();                                        
    {};
    switch (OSTCBCur->OSTCBStatPend) {                 
        case 0u:
             *perr = 0u;
             break;

        case 2u:
             *perr = 14u;                
             break;

        case 1u:
        default:
             OS_EventTaskRemove(OSTCBCur, pevent);
             *perr = 10u;                   
             break;
    }
    OSTCBCur->OSTCBStat          =  0x00u;       
    OSTCBCur->OSTCBStatPend      =  0u;   
    OSTCBCur->OSTCBEventPtr      = (OS_EVENT  *)0;     

    OSTCBCur->OSTCBEventMultiPtr = (OS_EVENT **)0;
    OSTCBCur->OSTCBEventMultiRdy = (OS_EVENT  *)0;

    {};

    ;
}
























 

INT8U  OSMutexPost (OS_EVENT *pevent)
{
    INT8U      pcp;                                    
    INT8U      prio;





    if (OSIntNesting > 0u) {                           
        return (5u);                      
    }

    if (pevent == (OS_EVENT *)0) {                     
        return (4u);
    }


    ;

    if (pevent->OSEventType != 4u) {  
        ;
        return (1u);
    }
    {};
    pcp  = (INT8U)(pevent->OSEventCnt >> 8u);          
    prio = (INT8U)(pevent->OSEventCnt & ((INT16U)0x00FFu));   
    if (OSTCBCur != (OS_TCB *)pevent->OSEventPtr) {    
        {};
        ;
        return (100u);
    }
    if (pcp != 0xFFu) {
        if (OSTCBCur->OSTCBPrio == pcp) {              
            ;
            OSMutex_RdyAtPrio(OSTCBCur, prio);         
        }
        OSTCBPrioTbl[pcp] = ((OS_TCB *)1);           
    }
    if (pevent->OSEventGrp != 0u) {                    
                                                       
        prio                = OS_EventTaskRdy(pevent, (void *)0, 0x10u, 0u);
        pevent->OSEventCnt &= ((INT16U)0xFF00u);   
        pevent->OSEventCnt |= (INT16U)prio;
        pevent->OSEventPtr  = OSTCBPrioTbl[prio];      
        if ((pcp  != 0xFFu) &&
            (prio <= pcp)) {                           
            {};                        
            OS_Sched();                                
            ;
            return (120u);
        } else {
            {};
            OS_Sched();                                
            ;
            return (0u);
        }
    }
    pevent->OSEventCnt |= ((INT16U)0x00FFu);          
    pevent->OSEventPtr  = (void *)0;
    {};
    ;
    return (0u);
}


















 


INT8U  OSMutexQuery (OS_EVENT       *pevent,
                     OS_MUTEX_DATA  *p_mutex_data)
{
    INT8U       i;
    OS_PRIO    *psrc;
    OS_PRIO    *pdest;






    if (OSIntNesting > 0u) {                                
        return (6u);                          
    }

    if (pevent == (OS_EVENT *)0) {                          
        return (4u);
    }
    if (p_mutex_data == (OS_MUTEX_DATA *)0) {               
        return (9u);
    }

    if (pevent->OSEventType != 4u) {       
        return (1u);
    }
    {};
    p_mutex_data->OSMutexPCP  = (INT8U)(pevent->OSEventCnt >> 8u);
    p_mutex_data->OSOwnerPrio = (INT8U)(pevent->OSEventCnt & ((INT16U)0x00FFu));
    if (p_mutex_data->OSOwnerPrio == 0xFFu) {
        p_mutex_data->OSValue = 1u;
    } else {
        p_mutex_data->OSValue = 0u;
    }
    p_mutex_data->OSEventGrp  = pevent->OSEventGrp;         
    psrc                      = &pevent->OSEventTbl[0];
    pdest                     = &p_mutex_data->OSEventTbl[0];
    for (i = 0u; i < ((63u) / 8u + 1u); i++) {
        *pdest++ = *psrc++;
    }
    {};
    return (0u);
}















 

static  void  OSMutex_RdyAtPrio (OS_TCB  *ptcb,
                                 INT8U    prio)
{
    INT8U  y;


    y            =  ptcb->OSTCBY;                           
    OSRdyTbl[y] &= (OS_PRIO)~ptcb->OSTCBBitX;
    ;
    if (OSRdyTbl[y] == 0u) {
        OSRdyGrp &= (OS_PRIO)~ptcb->OSTCBBitY;
    }
    ptcb->OSTCBPrio         = prio;
    OSPrioCur               = prio;                         

    ptcb->OSTCBY            = (INT8U)((INT8U)(prio >> 3u) & 0x07u);
    ptcb->OSTCBX            = (INT8U)(prio & 0x07u);




    ptcb->OSTCBBitY         = (OS_PRIO)(1uL << ptcb->OSTCBY);
    ptcb->OSTCBBitX         = (OS_PRIO)(1uL << ptcb->OSTCBX);
    OSRdyGrp               |= ptcb->OSTCBBitY;              
    OSRdyTbl[ptcb->OSTCBY] |= ptcb->OSTCBBitX;
    OSTCBPrioTbl[prio]      = ptcb;
    ;
}


#line 35 "UCOS_Source\\ucos_ii.c"
#line 1 ".\\UCOS_Source\\os_q.c"














 










 








































 


void  *OSQAccept (OS_EVENT  *pevent,
                  INT8U     *perr)
{
    void      *pmsg;
    OS_Q      *pq;






#line 87 ".\\UCOS_Source\\os_q.c"


    if (pevent == (OS_EVENT *)0) {                
        *perr = 4u;
        return ((void *)0);
    }

    if (pevent->OSEventType != 2u) { 
        *perr = 1u;
        return ((void *)0);
    }
    {};
    pq = (OS_Q *)pevent->OSEventPtr;              
    if (pq->OSQEntries > 0u) {                    
        pmsg = *pq->OSQOut++;                     
        pq->OSQEntries--;                         
        if (pq->OSQOut == pq->OSQEnd) {           
            pq->OSQOut = pq->OSQStart;
        }
        *perr = 0u;
    } else {
        *perr = 31u;
        pmsg  = (void *)0;                        
    }
    {};
    return (pmsg);                                
}




















 

OS_EVENT  *OSQCreate (void    **start,
                      INT16U    size)
{
    OS_EVENT  *pevent;
    OS_Q      *pq;






#line 153 ".\\UCOS_Source\\os_q.c"

    if (OSIntNesting > 0u) {                      
        return ((OS_EVENT *)0);                   
    }
    {};
    pevent = OSEventFreeList;                     
    if (OSEventFreeList != (OS_EVENT *)0) {       
        OSEventFreeList = (OS_EVENT *)OSEventFreeList->OSEventPtr;
    }
    {};
    if (pevent != (OS_EVENT *)0) {                
        {};
        pq = OSQFreeList;                         
        if (pq != (OS_Q *)0) {                    
            OSQFreeList            = OSQFreeList->OSQPtr;  
            {};
            pq->OSQStart           = start;                
            pq->OSQEnd             = &start[size];
            pq->OSQIn              = start;
            pq->OSQOut             = start;
            pq->OSQSize            = size;
            pq->OSQEntries         = 0u;
            pevent->OSEventType    = 2u;
            pevent->OSEventCnt     = 0u;
            pevent->OSEventPtr     = pq;

            pevent->OSEventName    = (INT8U *)(void *)"?";

            OS_EventWaitListInit(pevent);                  

            ;
        } else {
            pevent->OSEventPtr = (void *)OSEventFreeList;  
            OSEventFreeList    = pevent;
            {};
            pevent = (OS_EVENT *)0;
        }
    }
    return (pevent);
}













































 


OS_EVENT  *OSQDel (OS_EVENT  *pevent,
                   INT8U      opt,
                   INT8U     *perr)
{
    BOOLEAN    tasks_waiting;
    OS_EVENT  *pevent_return;
    OS_Q      *pq;





#line 259 ".\\UCOS_Source\\os_q.c"

#line 267 ".\\UCOS_Source\\os_q.c"


    if (pevent == (OS_EVENT *)0) {                          
        *perr = 4u;
        return (pevent);
    }


    ;

    if (pevent->OSEventType != 2u) {           
        *perr = 1u;
        ;
        return (pevent);
    }
    if (OSIntNesting > 0u) {                                
        *perr = 15u;                             
        ;
        return (pevent);
    }
    {};
    if (pevent->OSEventGrp != 0u) {                         
        tasks_waiting = 1u;                            
    } else {
        tasks_waiting = 0u;                           
    }
    switch (opt) {
        case 0u:                                
             if (tasks_waiting == 0u) {

                 pevent->OSEventName    = (INT8U *)(void *)"?";

                 pq                     = (OS_Q *)pevent->OSEventPtr;   
                 pq->OSQPtr             = OSQFreeList;
                 OSQFreeList            = pq;
                 pevent->OSEventType    = 0u;
                 pevent->OSEventPtr     = OSEventFreeList;  
                 pevent->OSEventCnt     = 0u;
                 OSEventFreeList        = pevent;           
                 {};
                 *perr                  = 0u;
                 pevent_return          = (OS_EVENT *)0;    
             } else {
                 {};
                 *perr                  = 73u;
                 pevent_return          = pevent;
             }
             break;

        case 1u:                                 
             while (pevent->OSEventGrp != 0u) {             
                 (void)OS_EventTaskRdy(pevent, (void *)0, 0x04u, 2u);
             }

             pevent->OSEventName    = (INT8U *)(void *)"?";

             pq                     = (OS_Q *)pevent->OSEventPtr;    
             pq->OSQPtr             = OSQFreeList;
             OSQFreeList            = pq;
             pevent->OSEventType    = 0u;
             pevent->OSEventPtr     = OSEventFreeList;      
             pevent->OSEventCnt     = 0u;
             OSEventFreeList        = pevent;               
             {};
             if (tasks_waiting == 1u) {                
                 OS_Sched();                                
             }
             *perr                  = 0u;
             pevent_return          = (OS_EVENT *)0;        
             break;

        default:
             {};
             *perr                  = 7u;
             pevent_return          = pevent;
             break;
    }

    ;

    return (pevent_return);
}




















 


INT8U  OSQFlush (OS_EVENT *pevent)
{
    OS_Q      *pq;







    if (pevent == (OS_EVENT *)0) {                     
        return (4u);
    }
    if (pevent->OSEventType != 2u) {      
        return (1u);
    }

    {};
    pq             = (OS_Q *)pevent->OSEventPtr;       
    pq->OSQIn      = pq->OSQStart;
    pq->OSQOut     = pq->OSQStart;
    pq->OSQEntries = 0u;
    {};
    return (0u);
}





































 

void  *OSQPend (OS_EVENT  *pevent,
                INT32U     timeout,
                INT8U     *perr)
{
    void      *pmsg;
    OS_Q      *pq;





#line 453 ".\\UCOS_Source\\os_q.c"


    if (pevent == (OS_EVENT *)0) {                
        *perr = 4u;
        return ((void *)0);
    }


    ;

    if (pevent->OSEventType != 2u) { 
        *perr = 1u;
        ;
        return ((void *)0);
    }
    if (OSIntNesting > 0u) {                      
        *perr = 2u;                  
        ;
        return ((void *)0);
    }
    if (OSLockNesting > 0u) {                     
        *perr = 13u;               
        ;
        return ((void *)0);
    }
    {};
    pq = (OS_Q *)pevent->OSEventPtr;              
    if (pq->OSQEntries > 0u) {                    
        pmsg = *pq->OSQOut++;                     
        pq->OSQEntries--;                         
        if (pq->OSQOut == pq->OSQEnd) {           
            pq->OSQOut = pq->OSQStart;
        }
        {};
        *perr = 0u;
        ;
        return (pmsg);                            
    }
    OSTCBCur->OSTCBStat     |= 0x04u;         
    OSTCBCur->OSTCBStatPend  = 0u;
    OSTCBCur->OSTCBDly       = timeout;           
    OS_EventTaskWait(pevent);                     
    {};
    OS_Sched();                                   
    {};
    switch (OSTCBCur->OSTCBStatPend) {                 
        case 0u:                          
             pmsg =  OSTCBCur->OSTCBMsg;
            *perr =  0u;
             break;

        case 2u:
             pmsg = (void *)0;
            *perr =  14u;                
             break;

        case 1u:
        default:
             OS_EventTaskRemove(OSTCBCur, pevent);
             pmsg = (void *)0;
            *perr =  10u;                   
             break;
    }
    OSTCBCur->OSTCBStat          =  0x00u;       
    OSTCBCur->OSTCBStatPend      =  0u;   
    OSTCBCur->OSTCBEventPtr      = (OS_EVENT  *)0;     

    OSTCBCur->OSTCBEventMultiPtr = (OS_EVENT **)0;
    OSTCBCur->OSTCBEventMultiRdy = (OS_EVENT  *)0;

    OSTCBCur->OSTCBMsg           = (void      *)0;     
    {};
    ;

    return (pmsg);                                     
}
































 


INT8U  OSQPendAbort (OS_EVENT  *pevent,
                     INT8U      opt,
                     INT8U     *perr)
{
    INT8U      nbr_tasks;






#line 581 ".\\UCOS_Source\\os_q.c"


    if (pevent == (OS_EVENT *)0) {                          
        *perr = 4u;
        return (0u);
    }

    if (pevent->OSEventType != 2u) {           
        *perr = 1u;
        return (0u);
    }
    {};
    if (pevent->OSEventGrp != 0u) {                         
        nbr_tasks = 0u;
        switch (opt) {
            case 1u:                     
                 while (pevent->OSEventGrp != 0u) {         
                     (void)OS_EventTaskRdy(pevent, (void *)0, 0x04u, 2u);
                     nbr_tasks++;
                 }
                 break;

            case 0u:
            default:                                        
                 (void)OS_EventTaskRdy(pevent, (void *)0, 0x04u, 2u);
                 nbr_tasks++;
                 break;
        }
        {};
        OS_Sched();                                         
        *perr = 14u;
        return (nbr_tasks);
    }
    {};
    *perr = 0u;
    return (0u);                                            
}




















 


INT8U  OSQPost (OS_EVENT  *pevent,
                void      *pmsg)
{
    OS_Q      *pq;






    if (pevent == (OS_EVENT *)0) {                      
        return (4u);
    }


    ;

    if (pevent->OSEventType != 2u) {       
        ;
        return (1u);
    }
    {};
    if (pevent->OSEventGrp != 0u) {                     
                                                        
        (void)OS_EventTaskRdy(pevent, pmsg, 0x04u, 0u);
        {};
        OS_Sched();                                     
        ;
        return (0u);
    }
    pq = (OS_Q *)pevent->OSEventPtr;                    
    if (pq->OSQEntries >= pq->OSQSize) {                
        {};
        ;
        return (30u);
    }
    *pq->OSQIn++ = pmsg;                                
    pq->OSQEntries++;                                   
    if (pq->OSQIn == pq->OSQEnd) {                      
        pq->OSQIn = pq->OSQStart;
    }
    {};
    ;

    return (0u);
}






















 


INT8U  OSQPostFront (OS_EVENT  *pevent,
                     void      *pmsg)
{
    OS_Q      *pq;







    if (pevent == (OS_EVENT *)0) {                     
        return (4u);
    }


    ;

    if (pevent->OSEventType != 2u) {      
        ;
        return (1u);
    }
    {};
    if (pevent->OSEventGrp != 0u) {                    
                                                       
        (void)OS_EventTaskRdy(pevent, pmsg, 0x04u, 0u);
        {};
        OS_Sched();                                    
        ;
        return (0u);
    }
    pq = (OS_Q *)pevent->OSEventPtr;                   
    if (pq->OSQEntries >= pq->OSQSize) {               
        {};
        ;
        return (30u);
    }
    if (pq->OSQOut == pq->OSQStart) {                  
        pq->OSQOut = pq->OSQEnd;
    }
    pq->OSQOut--;
    *pq->OSQOut = pmsg;                                
    pq->OSQEntries++;                                  
    {};
    ;
    return (0u);
}






























 


INT8U  OSQPostOpt (OS_EVENT  *pevent,
                   void      *pmsg,
                   INT8U      opt)
{
    OS_Q      *pq;







    if (pevent == (OS_EVENT *)0) {                     
        return (4u);
    }


    ;

    if (pevent->OSEventType != 2u) {      
        ;
        return (1u);
    }
    {};
    if (pevent->OSEventGrp != 0x00u) {                 
        if ((opt & 0x01u) != 0x00u) {  
            while (pevent->OSEventGrp != 0u) {         
                (void)OS_EventTaskRdy(pevent, pmsg, 0x04u, 0u);
            }
        } else {                                       
            (void)OS_EventTaskRdy(pevent, pmsg, 0x04u, 0u);
        }
        {};
        if ((opt & 0x04u) == 0u) {      
            OS_Sched();                                
        }
        ;
        return (0u);
    }
    pq = (OS_Q *)pevent->OSEventPtr;                   
    if (pq->OSQEntries >= pq->OSQSize) {               
        {};
        ;
        return (30u);
    }
    if ((opt & 0x02u) != 0x00u) {          
        if (pq->OSQOut == pq->OSQStart) {              
            pq->OSQOut = pq->OSQEnd;                   
        }
        pq->OSQOut--;
        *pq->OSQOut = pmsg;                            
    } else {                                           
        *pq->OSQIn++ = pmsg;                           
        if (pq->OSQIn == pq->OSQEnd) {                 
            pq->OSQIn = pq->OSQStart;
        }
    }
    pq->OSQEntries++;                                  
    {};
    ;
    return (0u);
}



















 


INT8U  OSQQuery (OS_EVENT  *pevent,
                 OS_Q_DATA *p_q_data)
{
    OS_Q       *pq;
    INT8U       i;
    OS_PRIO    *psrc;
    OS_PRIO    *pdest;







    if (pevent == (OS_EVENT *)0) {                      
        return (4u);
    }
    if (p_q_data == (OS_Q_DATA *)0) {                   
        return (9u);
    }

    if (pevent->OSEventType != 2u) {       
        return (1u);
    }
    {};
    p_q_data->OSEventGrp = pevent->OSEventGrp;          
    psrc                 = &pevent->OSEventTbl[0];
    pdest                = &p_q_data->OSEventTbl[0];
    for (i = 0u; i < ((63u) / 8u + 1u); i++) {
        *pdest++ = *psrc++;
    }
    pq = (OS_Q *)pevent->OSEventPtr;
    if (pq->OSQEntries > 0u) {
        p_q_data->OSMsg = *pq->OSQOut;                  
    } else {
        p_q_data->OSMsg = (void *)0;
    }
    p_q_data->OSNMsgs = pq->OSQEntries;
    p_q_data->OSQSize = pq->OSQSize;
    {};
    return (0u);
}
















 

void  OS_QInit (void)
{






    INT16U   ix;
    INT16U   ix_next;
    OS_Q    *pq1;
    OS_Q    *pq2;



    OS_MemClr((INT8U *)&OSQTbl[0], sizeof(OSQTbl));   
    for (ix = 0u; ix < (4u - 1u); ix++) {      
        ix_next = ix + 1u;
        pq1 = &OSQTbl[ix];
        pq2 = &OSQTbl[ix_next];
        pq1->OSQPtr = pq2;
    }
    pq1         = &OSQTbl[ix];
    pq1->OSQPtr = (OS_Q *)0;
    OSQFreeList = &OSQTbl[0];

}
#line 36 "UCOS_Source\\ucos_ii.c"
#line 1 ".\\UCOS_Source\\os_sem.c"














 










 



























 


INT16U  OSSemAccept (OS_EVENT *pevent)
{
    INT16U     cnt;







    if (pevent == (OS_EVENT *)0) {                     
        return (0u);
    }

    if (pevent->OSEventType != 3u) {    
        return (0u);
    }
    {};
    cnt = pevent->OSEventCnt;
    if (cnt > 0u) {                                    
        pevent->OSEventCnt--;                          
    }
    {};
    return (cnt);                                      
}


















 

OS_EVENT  *OSSemCreate (INT16U cnt)
{
    OS_EVENT  *pevent;





#line 116 ".\\UCOS_Source\\os_sem.c"

    if (OSIntNesting > 0u) {                                
        return ((OS_EVENT *)0);                             
    }
    {};
    pevent = OSEventFreeList;                               
    if (OSEventFreeList != (OS_EVENT *)0) {                 
        OSEventFreeList = (OS_EVENT *)OSEventFreeList->OSEventPtr;
    }
    {};
    if (pevent != (OS_EVENT *)0) {                          
        pevent->OSEventType    = 3u;
        pevent->OSEventCnt     = cnt;                       
        pevent->OSEventPtr     = (void *)0;                 

        pevent->OSEventName    = (INT8U *)(void *)"?";

        OS_EventWaitListInit(pevent);                       

        ;
    }
    return (pevent);
}











































 


OS_EVENT  *OSSemDel (OS_EVENT  *pevent,
                     INT8U      opt,
                     INT8U     *perr)
{
    BOOLEAN    tasks_waiting;
    OS_EVENT  *pevent_return;





#line 202 ".\\UCOS_Source\\os_sem.c"

#line 210 ".\\UCOS_Source\\os_sem.c"


    if (pevent == (OS_EVENT *)0) {                          
        *perr = 4u;
        return (pevent);
    }


    ;

    if (pevent->OSEventType != 3u) {         
        *perr = 1u;
        ;
        return (pevent);
    }
    if (OSIntNesting > 0u) {                                
        *perr = 15u;                             
        ;
        return (pevent);
    }
    {};
    if (pevent->OSEventGrp != 0u) {                         
        tasks_waiting = 1u;                            
    } else {
        tasks_waiting = 0u;                           
    }
    switch (opt) {
        case 0u:                                
             if (tasks_waiting == 0u) {

                 pevent->OSEventName    = (INT8U *)(void *)"?";

                 pevent->OSEventType    = 0u;
                 pevent->OSEventPtr     = OSEventFreeList;  
                 pevent->OSEventCnt     = 0u;
                 OSEventFreeList        = pevent;           
                 {};
                 *perr                  = 0u;
                 pevent_return          = (OS_EVENT *)0;    
             } else {
                 {};
                 *perr                  = 73u;
                 pevent_return          = pevent;
             }
             break;

        case 1u:                                 
             while (pevent->OSEventGrp != 0u) {             
                 (void)OS_EventTaskRdy(pevent, (void *)0, 0x01u, 2u);
             }

             pevent->OSEventName    = (INT8U *)(void *)"?";

             pevent->OSEventType    = 0u;
             pevent->OSEventPtr     = OSEventFreeList;      
             pevent->OSEventCnt     = 0u;
             OSEventFreeList        = pevent;               
             {};
             if (tasks_waiting == 1u) {                
                 OS_Sched();                                
             }
             *perr                  = 0u;
             pevent_return          = (OS_EVENT *)0;        
             break;

        default:
             {};
             *perr                  = 7u;
             pevent_return          = pevent;
             break;
    }

    ;

    return (pevent_return);
}

































 

void  OSSemPend (OS_EVENT  *pevent,
                 INT32U     timeout,
                 INT8U     *perr)
{





#line 336 ".\\UCOS_Source\\os_sem.c"


    if (pevent == (OS_EVENT *)0) {                     
        *perr = 4u;
        return;
    }


    ;

    if (pevent->OSEventType != 3u) {    
        *perr = 1u;
        ;
        return;
    }
    if (OSIntNesting > 0u) {                           
        *perr = 2u;                       
        ;
        return;
    }
    if (OSLockNesting > 0u) {                          
        *perr = 13u;                    
        ;
        return;
    }
    {};
    if (pevent->OSEventCnt > 0u) {                     
        pevent->OSEventCnt--;                          
        {};
        *perr = 0u;
        ;
        return;
    }
                                                       
    OSTCBCur->OSTCBStat     |= 0x01u;            
    OSTCBCur->OSTCBStatPend  = 0u;
    OSTCBCur->OSTCBDly       = timeout;                
    OS_EventTaskWait(pevent);                          
    {};
    OS_Sched();                                        
    {};
    switch (OSTCBCur->OSTCBStatPend) {                 
        case 0u:
             *perr = 0u;
             break;

        case 2u:
             *perr = 14u;                
             break;

        case 1u:
        default:
             OS_EventTaskRemove(OSTCBCur, pevent);
             *perr = 10u;                   
             break;
    }
    OSTCBCur->OSTCBStat          =  0x00u;       
    OSTCBCur->OSTCBStatPend      =  0u;   
    OSTCBCur->OSTCBEventPtr      = (OS_EVENT  *)0;     

    OSTCBCur->OSTCBEventMultiPtr = (OS_EVENT **)0;
    OSTCBCur->OSTCBEventMultiRdy = (OS_EVENT  *)0;

    {};

    ;
}

































 


INT8U  OSSemPendAbort (OS_EVENT  *pevent,
                       INT8U      opt,
                       INT8U     *perr)
{
    INT8U      nbr_tasks;





#line 455 ".\\UCOS_Source\\os_sem.c"


    if (pevent == (OS_EVENT *)0) {                     
        *perr = 4u;
        return (0u);
    }

    if (pevent->OSEventType != 3u) {    
        *perr = 1u;
        return (0u);
    }
    {};
    if (pevent->OSEventGrp != 0u) {                    
        nbr_tasks = 0u;
        switch (opt) {
            case 1u:                
                 while (pevent->OSEventGrp != 0u) {    
                     (void)OS_EventTaskRdy(pevent, (void *)0, 0x01u, 2u);
                     nbr_tasks++;
                 }
                 break;

            case 0u:
            default:                                   
                 (void)OS_EventTaskRdy(pevent, (void *)0, 0x01u, 2u);
                 nbr_tasks++;
                 break;
        }
        {};
        OS_Sched();                                    
        *perr = 14u;
        return (nbr_tasks);
    }
    {};
    *perr = 0u;
    return (0u);                                       
}



















 

INT8U  OSSemPost (OS_EVENT *pevent)
{






    if (pevent == (OS_EVENT *)0) {                     
        return (4u);
    }


    ;

    if (pevent->OSEventType != 3u) {    
        ;
        return (1u);
    }
    {};
    if (pevent->OSEventGrp != 0u) {                    
                                                       
        (void)OS_EventTaskRdy(pevent, (void *)0, 0x01u, 0u);
        {};
        OS_Sched();                                    
        ;
        return (0u);
    }
    if (pevent->OSEventCnt < 65535u) {                 
        pevent->OSEventCnt++;                          
        {};
        ;
        return (0u);
    }
    {};                                
    ;

    return (51u);
}



















 


INT8U  OSSemQuery (OS_EVENT     *pevent,
                   OS_SEM_DATA  *p_sem_data)
{
    INT8U       i;
    OS_PRIO    *psrc;
    OS_PRIO    *pdest;







    if (pevent == (OS_EVENT *)0) {                          
        return (4u);
    }
    if (p_sem_data == (OS_SEM_DATA *)0) {                   
        return (9u);
    }

    if (pevent->OSEventType != 3u) {         
        return (1u);
    }
    {};
    p_sem_data->OSEventGrp = pevent->OSEventGrp;            
    psrc                   = &pevent->OSEventTbl[0];
    pdest                  = &p_sem_data->OSEventTbl[0];
    for (i = 0u; i < ((63u) / 8u + 1u); i++) {
        *pdest++ = *psrc++;
    }
    p_sem_data->OSCnt = pevent->OSEventCnt;                 
    {};
    return (0u);
}

























 


void  OSSemSet (OS_EVENT  *pevent,
                INT16U     cnt,
                INT8U     *perr)
{






#line 652 ".\\UCOS_Source\\os_sem.c"


    if (pevent == (OS_EVENT *)0) {                     
        *perr = 4u;
        return;
    }

    if (pevent->OSEventType != 3u) {    
        *perr = 1u;
        return;
    }
    {};
    *perr = 0u;
    if (pevent->OSEventCnt > 0u) {                     
        pevent->OSEventCnt = cnt;                      
    } else {                                           
        if (pevent->OSEventGrp == 0u) {                
            pevent->OSEventCnt = cnt;                  
        } else {
            *perr              = 73u;
        }
    }
    {};
}


#line 37 "UCOS_Source\\ucos_ii.c"
#line 1 ".\\UCOS_Source\\os_task.c"














 










 






























 


INT8U  OSTaskChangePrio (INT8U  oldprio,
                         INT8U  newprio)
{

    OS_EVENT  *pevent;

    OS_EVENT **pevents;


    OS_TCB    *ptcb;
    INT8U      y_new;
    INT8U      x_new;
    INT8U      y_old;
    OS_PRIO    bity_new;
    OS_PRIO    bitx_new;
    OS_PRIO    bity_old;
    OS_PRIO    bitx_old;






    if (oldprio >= 63u) {
        if (oldprio != 0xFFu) {
            return (42u);
        }
    }
    if (newprio >= 63u) {
        return (42u);
    }

    {};
    if (OSTCBPrioTbl[newprio] != (OS_TCB *)0) {              
        {};
        return (40u);
    }
    if (oldprio == 0xFFu) {                           
        oldprio = OSTCBCur->OSTCBPrio;                       
    }
    ptcb = OSTCBPrioTbl[oldprio];
    if (ptcb == (OS_TCB *)0) {                               
        {};                                  
        return (41u);
    }
    if (ptcb == ((OS_TCB *)1)) {                           
        {};                                  
        return (67u);
    }

    y_new                 = (INT8U)(newprio >> 3u);          
    x_new                 = (INT8U)(newprio & 0x07u);




    bity_new              = (OS_PRIO)(1uL << y_new);
    bitx_new              = (OS_PRIO)(1uL << x_new);

    OSTCBPrioTbl[oldprio] = (OS_TCB *)0;                     
    OSTCBPrioTbl[newprio] =  ptcb;                           
    y_old                 =  ptcb->OSTCBY;
    bity_old              =  ptcb->OSTCBBitY;
    bitx_old              =  ptcb->OSTCBBitX;
    if ((OSRdyTbl[y_old] &   bitx_old) != 0u) {              
         OSRdyTbl[y_old] &= (OS_PRIO)~bitx_old;
         if (OSRdyTbl[y_old] == 0u) {
             OSRdyGrp &= (OS_PRIO)~bity_old;
         }
         OSRdyGrp        |= bity_new;                        
         OSRdyTbl[y_new] |= bitx_new;
         ;
    }


    pevent = ptcb->OSTCBEventPtr;
    if (pevent != (OS_EVENT *)0) {
        pevent->OSEventTbl[y_old] &= (OS_PRIO)~bitx_old;     
        if (pevent->OSEventTbl[y_old] == 0u) {
            pevent->OSEventGrp    &= (OS_PRIO)~bity_old;
        }
        pevent->OSEventGrp        |= bity_new;               
        pevent->OSEventTbl[y_new] |= bitx_new;
    }

    if (ptcb->OSTCBEventMultiPtr != (OS_EVENT **)0) {
        pevents =  ptcb->OSTCBEventMultiPtr;
        pevent  = *pevents;
        while (pevent != (OS_EVENT *)0) {
            pevent->OSEventTbl[y_old] &= (OS_PRIO)~bitx_old;    
            if (pevent->OSEventTbl[y_old] == 0u) {
                pevent->OSEventGrp    &= (OS_PRIO)~bity_old;
            }
            pevent->OSEventGrp        |= bity_new;           
            pevent->OSEventTbl[y_new] |= bitx_new;
            pevents++;
            pevent                     = *pevents;
        }
    }



    ptcb->OSTCBPrio = newprio;                               
    ptcb->OSTCBY    = y_new;
    ptcb->OSTCBX    = x_new;
    ptcb->OSTCBBitY = bity_new;
    ptcb->OSTCBBitX = bitx_new;
    {};
    if (OSRunning == 1u) {
        OS_Sched();                                          
    }
    return (0u);
}











































 


INT8U  OSTaskCreate (void   (*task)(void *p_arg),
                     void    *p_arg,
                     OS_STK  *ptos,
                     INT8U    prio)
{
    OS_STK     *psp;
    INT8U       err;






#line 238 ".\\UCOS_Source\\os_task.c"


    if (prio > 63u) {              
        return (42u);
    }

    {};
    if (OSIntNesting > 0u) {                  
        {};
        return (60u);
    }
    if (OSTCBPrioTbl[prio] == (OS_TCB *)0) {  
        OSTCBPrioTbl[prio] = ((OS_TCB *)1); 
                                              
        {};
        psp = OSTaskStkInit(task, p_arg, ptos, 0u);              
        err = OS_TCBInit(prio, psp, (OS_STK *)0, 0u, 0u, (void *)0, 0u);
        if (err == 0u) {
            ;
            if (OSRunning == 1u) {       
                OS_Sched();
            }
        } else {
            ;
            {};
            OSTCBPrioTbl[prio] = (OS_TCB *)0; 
            {};
        }
        return (err);
    }
    {};
    return (40u);
}









































































 


INT8U  OSTaskCreateExt (void   (*task)(void *p_arg),
                        void    *p_arg,
                        OS_STK  *ptos,
                        INT8U    prio,
                        INT16U   id,
                        OS_STK  *pbos,
                        INT32U   stk_size,
                        void    *pext,
                        INT16U   opt)
{
    OS_STK     *psp;
    INT8U       err;






#line 371 ".\\UCOS_Source\\os_task.c"


    if (prio > 63u) {              
        return (42u);
    }

    {};
    if (OSIntNesting > 0u) {                  
        {};
        return (60u);
    }
    if (OSTCBPrioTbl[prio] == (OS_TCB *)0) {  
        OSTCBPrioTbl[prio] = ((OS_TCB *)1); 
                                              
        {};


        OS_TaskStkClr(pbos, stk_size, opt);                     


        psp = OSTaskStkInit(task, p_arg, ptos, opt);            
        err = OS_TCBInit(prio, psp, pbos, id, stk_size, pext, opt);
        if (err == 0u) {
            ;
            if (OSRunning == 1u) {                         
                OS_Sched();
            }
        } else {
            {};
            OSTCBPrioTbl[prio] = (OS_TCB *)0;                   
            {};
        }
        return (err);
    }
    {};
    return (40u);
}







































 


INT8U  OSTaskDel (INT8U prio)
{

    OS_FLAG_NODE *pnode;

    OS_TCB       *ptcb;






#line 468 ".\\UCOS_Source\\os_task.c"

    if (OSIntNesting > 0u) {                             
        return (64u);
    }
    if (prio == (63u)) {                     
        return (62u);
    }

    if (prio >= 63u) {                        
        if (prio != 0xFFu) {
            return (42u);
        }
    }


    {};
    if (prio == 0xFFu) {                          
        prio = OSTCBCur->OSTCBPrio;                      
    }
    ptcb = OSTCBPrioTbl[prio];
    if (ptcb == (OS_TCB *)0) {                           
        {};
        return (67u);
    }
    if (ptcb == ((OS_TCB *)1)) {                       
        {};
        return (61u);
    }

    OSRdyTbl[ptcb->OSTCBY] &= (OS_PRIO)~ptcb->OSTCBBitX;
    ;
    if (OSRdyTbl[ptcb->OSTCBY] == 0u) {                  
        OSRdyGrp           &= (OS_PRIO)~ptcb->OSTCBBitY;
    }


    if (ptcb->OSTCBEventPtr != (OS_EVENT *)0) {
        OS_EventTaskRemove(ptcb, ptcb->OSTCBEventPtr);   
    }

    if (ptcb->OSTCBEventMultiPtr != (OS_EVENT **)0) {    
        OS_EventTaskRemoveMulti(ptcb, ptcb->OSTCBEventMultiPtr);
    }




    pnode = ptcb->OSTCBFlagNode;
    if (pnode != (OS_FLAG_NODE *)0) {                    
        OS_FlagUnlink(pnode);                            
    }


    ptcb->OSTCBDly      = 0u;                            
    ptcb->OSTCBStat     = 0x00u;                   
    ptcb->OSTCBStatPend = 0u;
    if (OSLockNesting < 255u) {                          
        OSLockNesting++;
    }
    {};                                  
    OS_Dummy();                                          
    {};                                 
    if (OSLockNesting > 0u) {                            
        OSLockNesting--;
    }
    OSTaskDelHook(ptcb);                                 







    OSTaskCtr--;                                         
    OSTCBPrioTbl[prio] = (OS_TCB *)0;                    
    if (ptcb->OSTCBPrev == (OS_TCB *)0) {                
        ptcb->OSTCBNext->OSTCBPrev = (OS_TCB *)0;
        OSTCBList                  = ptcb->OSTCBNext;
    } else {
        ptcb->OSTCBPrev->OSTCBNext = ptcb->OSTCBNext;
        ptcb->OSTCBNext->OSTCBPrev = ptcb->OSTCBPrev;
    }
    ptcb->OSTCBNext     = OSTCBFreeList;                 
    OSTCBFreeList       = ptcb;

    ptcb->OSTCBTaskName = (INT8U *)(void *)"?";

    {};
    if (OSRunning == 1u) {
        OS_Sched();                                      
    }
    return (0u);
}

















































 


INT8U  OSTaskDelReq (INT8U prio)
{
    INT8U      stat;
    OS_TCB    *ptcb;






#line 629 ".\\UCOS_Source\\os_task.c"

    if (prio == (63u)) {                             
        return (62u);
    }

    if (prio >= 63u) {                                
        if (prio != 0xFFu) {
            return (42u);
        }
    }

    if (prio == 0xFFu) {                                  
        {};                                     
        stat = OSTCBCur->OSTCBDelReq;                            
        {};
        return (stat);
    }
    {};
    ptcb = OSTCBPrioTbl[prio];
    if (ptcb == (OS_TCB *)0) {                                   
        {};
        return (67u);                          
    }
    if (ptcb == ((OS_TCB *)1)) {                               
        {};
        return (61u);
    }
    ptcb->OSTCBDelReq = 63u;                     
    {};
    return (0u);
}

























 


INT8U  OSTaskNameGet (INT8U    prio,
                      INT8U  **pname,
                      INT8U   *perr)
{
    OS_TCB    *ptcb;
    INT8U      len;






#line 706 ".\\UCOS_Source\\os_task.c"


    if (prio > 63u) {                          
        if (prio != 0xFFu) {
            *perr = 42u;                  
            return (0u);
        }
    }
    if (pname == (INT8U **)0) {                           
        *perr = 12u;                        
        return (0u);
    }

    if (OSIntNesting > 0u) {                               
        *perr = 17u;
        return (0u);
    }
    {};
    if (prio == 0xFFu) {                           
        prio = OSTCBCur->OSTCBPrio;
    }
    ptcb = OSTCBPrioTbl[prio];
    if (ptcb == (OS_TCB *)0) {                            
        {};                               
        *perr = 67u;
        return (0u);
    }
    if (ptcb == ((OS_TCB *)1)) {                        
        {};                               
        *perr = 67u;
        return (0u);
    }
    *pname = ptcb->OSTCBTaskName;
    len    = OS_StrLen(*pname);
    {};
    *perr  = 0u;
    return (len);
}
























 

void  OSTaskNameSet (INT8U   prio,
                     INT8U  *pname,
                     INT8U  *perr)
{
    OS_TCB    *ptcb;






#line 787 ".\\UCOS_Source\\os_task.c"


    if (prio > 63u) {                      
        if (prio != 0xFFu) {
            *perr = 42u;              
            return;
        }
    }
    if (pname == (INT8U *)0) {                        
        *perr = 12u;                    
        return;
    }

    if (OSIntNesting > 0u) {                          
        *perr = 18u;
        return;
    }
    {};
    if (prio == 0xFFu) {                       
        prio = OSTCBCur->OSTCBPrio;
    }
    ptcb = OSTCBPrioTbl[prio];
    if (ptcb == (OS_TCB *)0) {                        
        {};                           
        *perr = 67u;
        return;
    }
    if (ptcb == ((OS_TCB *)1)) {                    
        {};                           
        *perr = 67u;
        return;
    }
    ptcb->OSTCBTaskName = pname;
    ;
    {};
    *perr               = 0u;
}



















 


INT8U  OSTaskResume (INT8U prio)
{
    OS_TCB    *ptcb;







    if (prio >= 63u) {                              
        return (42u);
    }

    {};
    ptcb = OSTCBPrioTbl[prio];
    if (ptcb == (OS_TCB *)0) {                                 
        {};
        return (70u);
    }
    if (ptcb == ((OS_TCB *)1)) {                             
        {};
        return (67u);
    }
    if ((ptcb->OSTCBStat & 0x08u) != 0x00u) {  
        ptcb->OSTCBStat &= (INT8U)~(INT8U)0x08u;     
        if ((ptcb->OSTCBStat & (0x01u | 0x02u | 0x04u | 0x10u | 0x20u)) == 0x00u) {  
            if (ptcb->OSTCBDly == 0u) {
                OSRdyGrp               |= ptcb->OSTCBBitY;     
                OSRdyTbl[ptcb->OSTCBY] |= ptcb->OSTCBBitX;
                ;
                {};
                if (OSRunning == 1u) {
                    ;
                    OS_Sched();                                
                }
            } else {
                {};
            }
        } else {                                               
            {};
        }
        return (0u);
    }
    {};
    return (68u);
}





















 

INT8U  OSTaskStkChk (INT8U         prio,
                     OS_STK_DATA  *p_stk_data)
{
    OS_TCB    *ptcb;
    OS_STK    *pchk;
    INT32U     nfree;
    INT32U     size;







    if (prio > 63u) {                        
        if (prio != 0xFFu) {
            return (42u);
        }
    }
    if (p_stk_data == (OS_STK_DATA *)0) {               
        return (9u);
    }

    p_stk_data->OSFree = 0u;                            
    p_stk_data->OSUsed = 0u;
    {};
    if (prio == 0xFFu) {                         
        prio = OSTCBCur->OSTCBPrio;
    }
    ptcb = OSTCBPrioTbl[prio];
    if (ptcb == (OS_TCB *)0) {                          
        {};
        return (67u);
    }
    if (ptcb == ((OS_TCB *)1)) {
        {};
        return (67u);
    }
    if ((ptcb->OSTCBOpt & 0x0001u) == 0u) {  
        {};
        return (69u);
    }
    nfree = 0u;
    size  = ptcb->OSTCBStkSize;
    pchk  = ptcb->OSTCBStkBottom;
    {};





    while (*pchk-- == (OS_STK)0) {
        nfree++;
    }

    p_stk_data->OSFree = nfree;                        
    p_stk_data->OSUsed = size - nfree;                 
    return (0u);
}
























 


INT8U  OSTaskSuspend (INT8U prio)
{
    BOOLEAN    self;
    OS_TCB    *ptcb;
    INT8U      y;







    if (prio == (63u)) {                             
        return (71u);
    }
    if (prio >= 63u) {                                
        if (prio != 0xFFu) {
            return (42u);
        }
    }

    {};
    if (prio == 0xFFu) {                                  
        prio = OSTCBCur->OSTCBPrio;
        self = 1u;
    } else if (prio == OSTCBCur->OSTCBPrio) {                    
        self = 1u;
    } else {
        self = 0u;                                         
    }
    ptcb = OSTCBPrioTbl[prio];
    if (ptcb == (OS_TCB *)0) {                                   
        {};
        return (72u);
    }
    if (ptcb == ((OS_TCB *)1)) {                               
        {};
        return (67u);
    }
    y            = ptcb->OSTCBY;
    OSRdyTbl[y] &= (OS_PRIO)~ptcb->OSTCBBitX;                    
    if (OSRdyTbl[y] == 0u) {
        OSRdyGrp &= (OS_PRIO)~ptcb->OSTCBBitY;
    }
    ptcb->OSTCBStat |= 0x08u;                          
    {};
    ;
    ;
    if (self == 1u) {                                       
        OS_Sched();                                              
    }
    return (0u);
}




















 


INT8U  OSTaskQuery (INT8U    prio,
                    OS_TCB  *p_task_data)
{
    OS_TCB    *ptcb;







    if (prio > 63u) {                  
        if (prio != 0xFFu) {
            return (42u);
        }
    }
    if (p_task_data == (OS_TCB *)0) {             
        return (9u);
    }

    {};
    if (prio == 0xFFu) {                   
        prio = OSTCBCur->OSTCBPrio;
    }
    ptcb = OSTCBPrioTbl[prio];
    if (ptcb == (OS_TCB *)0) {                    
        {};
        return (41u);
    }
    if (ptcb == ((OS_TCB *)1)) {                
        {};
        return (67u);
    }
                                                  
    OS_MemCopy((INT8U *)p_task_data, (INT8U *)ptcb, sizeof(OS_TCB));
    {};
    return (0u);
}



























 


INT32U  OSTaskRegGet (INT8U   prio,
                      INT8U   id,
                      INT8U  *perr)
{



    INT32U     value;
    OS_TCB    *ptcb;



#line 1164 ".\\UCOS_Source\\os_task.c"


    if (prio >= 63u) {
        if (prio != 0xFFu) {
            *perr = 42u;
            return (0u);
        }
    }
    if (id >= 1u) {
        *perr = 8u;
        return (0u);
    }

    {};
    if (prio == 0xFFu) {                   
        ptcb = OSTCBCur;
    } else {
        ptcb = OSTCBPrioTbl[prio];
    }
    value = ptcb->OSTCBRegTbl[id];
    {};
    *perr = 0u;
    return (value);
}


















 


INT8U  OSTaskRegGetID (INT8U  *perr)
{



    INT8U      id;


#line 1223 ".\\UCOS_Source\\os_task.c"

    {};
    if (OSTaskRegNextAvailID >= 1u) {          
       *perr = 150u;                          
        {};
        return ((INT8U)1u);
    }

    id   = OSTaskRegNextAvailID;                                 
    OSTaskRegNextAvailID++;                                      
    {};
   *perr = 0u;
    return (id);
}





























 


void  OSTaskRegSet (INT8U    prio,
                    INT8U    id,
                    INT32U   value,
                    INT8U   *perr)
{



    OS_TCB    *ptcb;


#line 1286 ".\\UCOS_Source\\os_task.c"


    if (prio >= 63u) {
        if (prio != 0xFFu) {
            *perr = 42u;
            return;
        }
    }
    if (id >= 1u) {
        *perr = 8u;
        return;
    }

    {};
    if (prio == 0xFFu) {                   
        ptcb = OSTCBCur;
    } else {
        ptcb = OSTCBPrioTbl[prio];
    }
    ptcb->OSTCBRegTbl[id] = value;
    {};
    *perr                 = 0u;
}
















 

void  OS_TaskReturn (void)
{
    OSTaskReturnHook(OSTCBCur);                    


    (void)OSTaskDel(0xFFu);                 





}























 

void  OS_TaskStkClr (OS_STK  *pbos,
                     INT32U   size,
                     INT16U   opt)
{
    if ((opt & 0x0001u) != 0x0000u) {       
        if ((opt & 0x0002u) != 0x0000u) {   
#line 1376 ".\\UCOS_Source\\os_task.c"
            while (size > 0u) {                         
                size--;
                *pbos-- = (OS_STK)0;                    
            }

        }
    }
}

#line 38 "UCOS_Source\\ucos_ii.c"
#line 1 ".\\UCOS_Source\\os_time.c"














 










 
























 

void  OSTimeDly (INT32U ticks)
{
    INT8U      y;






    if (OSIntNesting > 0u) {                      
        return;
    }
    if (OSLockNesting > 0u) {                     
        return;
    }
    if (ticks > 0u) {                             
        {};
        y            =  OSTCBCur->OSTCBY;         
        OSRdyTbl[y] &= (OS_PRIO)~OSTCBCur->OSTCBBitX;
        ;
        if (OSRdyTbl[y] == 0u) {
            OSRdyGrp &= (OS_PRIO)~OSTCBCur->OSTCBBitY;
        }
        OSTCBCur->OSTCBDly = ticks;               
        ;
        {};
        OS_Sched();                               
    }
}


























 


INT8U  OSTimeDlyHMSM (INT8U   hours,
                      INT8U   minutes,
                      INT8U   seconds,
                      INT16U  ms)
{
    INT32U ticks;


    if (OSIntNesting > 0u) {                      
        return (85u);
    }
    if (OSLockNesting > 0u) {                     
        return (50u);
    }

    if (hours == 0u) {
        if (minutes == 0u) {
            if (seconds == 0u) {
                if (ms == 0u) {
                    return (84u);
                }
            }
        }
    }
    if (minutes > 59u) {
        return (81u);     
    }
    if (seconds > 59u) {
        return (82u);
    }
    if (ms > 999u) {
        return (83u);
    }

                                                  
                                                  
    ticks = ((INT32U)hours * 3600uL + (INT32U)minutes * 60uL + (INT32U)seconds) * 100u
          + 100u * ((INT32U)ms + 500uL / 100u) / 1000uL;
    OSTimeDly(ticks);
    return (0u);
}




















 


INT8U  OSTimeDlyResume (INT8U prio)
{
    OS_TCB    *ptcb;






    if (prio >= 63u) {
        return (42u);
    }
    {};
    ptcb = OSTCBPrioTbl[prio];                                  
    if (ptcb == (OS_TCB *)0) {
        {};
        return (67u);                         
    }
    if (ptcb == ((OS_TCB *)1)) {
        {};
        return (67u);                         
    }
    if (ptcb->OSTCBDly == 0u) {                                 
        {};
        return (80u);                           
    }

    ptcb->OSTCBDly = 0u;                                        
    if ((ptcb->OSTCBStat & (0x01u | 0x02u | 0x04u | 0x10u | 0x20u)) != 0x00u) {
        ptcb->OSTCBStat     &= ~(0x01u | 0x02u | 0x04u | 0x10u | 0x20u);               
        ptcb->OSTCBStatPend  =  1u;                
    } else {
        ptcb->OSTCBStatPend  =  0u;
    }
    if ((ptcb->OSTCBStat & 0x08u) == 0x00u) {   
        OSRdyGrp               |= ptcb->OSTCBBitY;              
        OSRdyTbl[ptcb->OSTCBY] |= ptcb->OSTCBBitX;
        ;
        {};
        OS_Sched();                                             
    } else {
        {};                                     
    }
    return (0u);
}














 


INT32U  OSTimeGet (void)
{
    INT32U     ticks;






    {};
    ticks = OSTime;
    {};
    return (ticks);
}













 


void  OSTimeSet (INT32U ticks)
{






    {};
    OSTime = ticks;
    {};
}
#line 39 "UCOS_Source\\ucos_ii.c"
#line 1 ".\\UCOS_Source\\os_tmr.c"














 










 





















 





 








 


static  OS_TMR  *OSTmr_Alloc         (void);
static  void     OSTmr_Free          (OS_TMR *ptmr);
static  void     OSTmr_InitTask      (void);
static  void     OSTmr_Link          (OS_TMR *ptmr, INT8U type);
static  void     OSTmr_Unlink        (OS_TMR *ptmr);
static  void     OSTmr_Task          (void   *p_arg);














































 


OS_TMR  *OSTmrCreate (INT32U           dly,
                      INT32U           period,
                      INT8U            opt,
                      OS_TMR_CALLBACK  callback,
                      void            *callback_arg,
                      INT8U           *pname,
                      INT8U           *perr)
{
    OS_TMR   *ptmr;


#line 138 ".\\UCOS_Source\\os_tmr.c"

#line 146 ".\\UCOS_Source\\os_tmr.c"


    switch (opt) {                                           
        case 2u:
             if (period == 0u) {
                 *perr = 131u;
                 return ((OS_TMR *)0);
             }
             break;

        case 1u:
             if (dly == 0u) {
                 *perr = 130u;
                 return ((OS_TMR *)0);
             }
             break;

        default:
             *perr = 132u;
             return ((OS_TMR *)0);
    }

    if (OSIntNesting > 0u) {                                 
        *perr  = 139u;
        return ((OS_TMR *)0);
    }
    OSSchedLock();
    ptmr = OSTmr_Alloc();                                    
    if (ptmr == (OS_TMR *)0) {
        OSSchedUnlock();
        *perr = 134u;
        return ((OS_TMR *)0);
    }
    ptmr->OSTmrState       = 1u;           
    ptmr->OSTmrDly         = dly;
    ptmr->OSTmrPeriod      = period;
    ptmr->OSTmrOpt         = opt;
    ptmr->OSTmrCallback    = callback;
    ptmr->OSTmrCallbackArg = callback_arg;

    if (pname == (INT8U *)0) {                               
        ptmr->OSTmrName    = (INT8U *)(void *)"?";
    } else {
        ptmr->OSTmrName    = pname;
    }

    OSSchedUnlock();
    ;
    *perr = 0u;
    return (ptmr);
}

























 


BOOLEAN  OSTmrDel (OS_TMR  *ptmr,
                   INT8U   *perr)
{
#line 234 ".\\UCOS_Source\\os_tmr.c"

#line 242 ".\\UCOS_Source\\os_tmr.c"


    if (ptmr == (OS_TMR *)0) {
        *perr = 138u;
        return (0u);
    }


    ;

    if (ptmr->OSTmrType != 100u) {                    
        *perr = 137u;
        ;
        return (0u);
    }
    if (OSIntNesting > 0u) {                                 
        *perr  = 139u;
        ;
        return (0u);
    }
    OSSchedLock();
    switch (ptmr->OSTmrState) {
        case 3u:
             OSTmr_Unlink(ptmr);                             
             OSTmr_Free(ptmr);                               
             OSSchedUnlock();
             *perr = 0u;
             ;
             return (1u);

        case 1u:                           
        case 2u:                         
             OSTmr_Free(ptmr);                               
             OSSchedUnlock();
             *perr = 0u;
             ;
             return (1u);

        case 0u:                            
             OSSchedUnlock();
             *perr = 135u;
             ;
             return (0u);

        default:
             OSSchedUnlock();
             *perr = 141u;
             ;
             return (0u);
    }
}
























 


INT8U  OSTmrNameGet (OS_TMR   *ptmr,
                     INT8U   **pdest,
                     INT8U    *perr)
{
    INT8U  len;


#line 333 ".\\UCOS_Source\\os_tmr.c"


    if (pdest == (INT8U **)0) {
        *perr = 136u;
        return (0u);
    }
    if (ptmr == (OS_TMR *)0) {
        *perr = 138u;
        return (0u);
    }

    if (ptmr->OSTmrType != 100u) {               
        *perr = 137u;
        return (0u);
    }
    if (OSIntNesting > 0u) {                            
        *perr = 17u;
        return (0u);
    }
    OSSchedLock();
    switch (ptmr->OSTmrState) {
        case 3u:
        case 1u:
        case 2u:
             *pdest = ptmr->OSTmrName;
             len    = OS_StrLen(*pdest);
             OSSchedUnlock();
             *perr = 0u;
             return (len);

        case 0u:                       
             OSSchedUnlock();
             *perr = 135u;
             return (0u);

        default:
             OSSchedUnlock();
             *perr = 141u;
             return (0u);
    }
}























 


INT32U  OSTmrRemainGet (OS_TMR  *ptmr,
                        INT8U   *perr)
{
    INT32U  remain;


#line 412 ".\\UCOS_Source\\os_tmr.c"


    if (ptmr == (OS_TMR *)0) {
        *perr = 138u;
        return (0u);
    }

    if (ptmr->OSTmrType != 100u) {               
        *perr = 137u;
        return (0u);
    }
    if (OSIntNesting > 0u) {                            
        *perr = 139u;
        return (0u);
    }
    OSSchedLock();
    switch (ptmr->OSTmrState) {
        case 3u:
             remain = ptmr->OSTmrMatch - OSTmrTime;     
             OSSchedUnlock();
             *perr  = 0u;
             return (remain);

        case 1u:                      
             switch (ptmr->OSTmrOpt) {
                 case 2u:
                      if (ptmr->OSTmrDly == 0u) {
                          remain = ptmr->OSTmrPeriod;
                      } else {
                          remain = ptmr->OSTmrDly;
                      }
                      OSSchedUnlock();
                      *perr  = 0u;
                      break;

                 case 1u:
                 default:
                      remain = ptmr->OSTmrDly;
                      OSSchedUnlock();
                      *perr  = 0u;
                      break;
             }
             return (remain);

        case 2u:                    
             OSSchedUnlock();
             *perr = 0u;
             return (0u);

        case 0u:
             OSSchedUnlock();
             *perr = 135u;
             return (0u);

        default:
             OSSchedUnlock();
             *perr = 141u;
             return (0u);
    }
}


























 


INT8U  OSTmrStateGet (OS_TMR  *ptmr,
                      INT8U   *perr)
{
    INT8U  state;


#line 513 ".\\UCOS_Source\\os_tmr.c"


    if (ptmr == (OS_TMR *)0) {
        *perr = 138u;
        return (0u);
    }

    if (ptmr->OSTmrType != 100u) {               
        *perr = 137u;
        return (0u);
    }
    if (OSIntNesting > 0u) {                            
        *perr = 139u;
        return (0u);
    }
    OSSchedLock();
    state = ptmr->OSTmrState;
    switch (state) {
        case 0u:
        case 1u:
        case 2u:
        case 3u:
             *perr = 0u;
             break;

        default:
             *perr = 141u;
             break;
    }
    OSSchedUnlock();
    return (state);
}






















 


BOOLEAN  OSTmrStart (OS_TMR   *ptmr,
                     INT8U    *perr)
{
#line 579 ".\\UCOS_Source\\os_tmr.c"


    if (ptmr == (OS_TMR *)0) {
        *perr = 138u;
        return (0u);
    }


    ;

    if (ptmr->OSTmrType != 100u) {                    
        *perr = 137u;
        ;
        return (0u);
    }
    if (OSIntNesting > 0u) {                                 
        *perr  = 139u;
        ;
        return (0u);
    }
    OSSchedLock();
    switch (ptmr->OSTmrState) {
        case 3u:                           
             OSTmr_Unlink(ptmr);                             
             OSTmr_Link(ptmr, 0u);              
             OSSchedUnlock();
             *perr = 0u;
             ;
             return (1u);

        case 1u:                           
        case 2u:
             OSTmr_Link(ptmr, 0u);              
             OSSchedUnlock();
             *perr = 0u;
             ;
             return (1u);

        case 0u:                            
             OSSchedUnlock();
             *perr = 135u;
             ;
             return (0u);

        default:
             OSSchedUnlock();
             *perr = 141u;
             ;
             return (0u);
    }
}






































 


BOOLEAN  OSTmrStop (OS_TMR  *ptmr,
                    INT8U    opt,
                    void    *callback_arg,
                    INT8U   *perr)
{
    OS_TMR_CALLBACK  pfnct;


#line 685 ".\\UCOS_Source\\os_tmr.c"


    if (ptmr == (OS_TMR *)0) {
        *perr = 138u;
        return (0u);
    }


    ;

    if (ptmr->OSTmrType != 100u) {                          
        *perr = 137u;
        ;
        return (0u);
    }
    if (OSIntNesting > 0u) {                                       
        *perr  = 139u;
        ;
        return (0u);
    }
    OSSchedLock();
    switch (ptmr->OSTmrState) {
        case 3u:
             OSTmr_Unlink(ptmr);                                   
             *perr = 0u;
             switch (opt) {
                 case 3u:
                      pfnct = ptmr->OSTmrCallback;                 
                      if (pfnct != (OS_TMR_CALLBACK)0) {
                          (*pfnct)((void *)ptmr, ptmr->OSTmrCallbackArg);   
                      } else {
                          *perr = 143u;
                      }
                      break;

                 case 4u:
                      pfnct = ptmr->OSTmrCallback;                 
                      if (pfnct != (OS_TMR_CALLBACK)0) {
                          (*pfnct)((void *)ptmr, callback_arg);    
                      } else {
                          *perr = 143u;
                      }
                      break;

                 case 0u:
                      break;

                 default:
                     *perr = 132u;
                     break;
             }
             OSSchedUnlock();
             ;
             return (1u);

        case 2u:                               
        case 1u:                                 
             OSSchedUnlock();
             *perr = 142u;
             ;
             return (1u);

        case 0u:                                  
             OSSchedUnlock();
             *perr = 135u;
             ;
             return (0u);

        default:
             OSSchedUnlock();
             *perr = 141u;
             ;
             return (0u);
    }
}




















 


INT8U  OSTmrSignal (void)
{
    INT8U  err;


    err = OSSemPost(OSTmrSemSignal);
    return (err);
}













 


static  OS_TMR  *OSTmr_Alloc (void)
{
    OS_TMR *ptmr;


    if (OSTmrFreeList == (OS_TMR *)0) {
        return ((OS_TMR *)0);
    }
    ptmr            = (OS_TMR *)OSTmrFreeList;
    OSTmrFreeList   = (OS_TMR *)ptmr->OSTmrNext;
    ptmr->OSTmrNext = (OS_TCB *)0;
    ptmr->OSTmrPrev = (OS_TCB *)0;
    OSTmrUsed++;
    OSTmrFree--;
    return (ptmr);
}













 


static  void  OSTmr_Free (OS_TMR *ptmr)
{
    ptmr->OSTmrState       = 0u;       
    ptmr->OSTmrOpt         = 0u;
    ptmr->OSTmrPeriod      = 0u;
    ptmr->OSTmrMatch       = 0u;
    ptmr->OSTmrCallback    = (OS_TMR_CALLBACK)0;
    ptmr->OSTmrCallbackArg = (void *)0;

    ptmr->OSTmrName        = (INT8U *)(void *)"?";


    ptmr->OSTmrPrev        = (OS_TCB *)0;               
    ptmr->OSTmrNext        = OSTmrFreeList;
    OSTmrFreeList          = ptmr;

    OSTmrUsed--;                                        
    OSTmrFree++;
}














 


void  OSTmr_Init (void)
{

    INT8U    err;

    INT16U   ix;
    INT16U   ix_next;
    OS_TMR  *ptmr1;
    OS_TMR  *ptmr2;


    OS_MemClr((INT8U *)&OSTmrTbl[0],      sizeof(OSTmrTbl));             
    OS_MemClr((INT8U *)&OSTmrWheelTbl[0], sizeof(OSTmrWheelTbl));        

    for (ix = 0u; ix < (16u - 1u); ix++) {                    
        ix_next = ix + 1u;
        ptmr1 = &OSTmrTbl[ix];
        ptmr2 = &OSTmrTbl[ix_next];
        ptmr1->OSTmrType    = 100u;
        ptmr1->OSTmrState   = 0u;                       
        ptmr1->OSTmrNext    = (void *)ptmr2;                             

        ptmr1->OSTmrName    = (INT8U *)(void *)"?";

    }
    ptmr1               = &OSTmrTbl[ix];
    ptmr1->OSTmrType    = 100u;
    ptmr1->OSTmrState   = 0u;                           
    ptmr1->OSTmrNext    = (void *)0;                                     

    ptmr1->OSTmrName    = (INT8U *)(void *)"?";

    OSTmrTime           = 0u;
    OSTmrUsed           = 0u;
    OSTmrFree           = 16u;
    OSTmrFreeList       = &OSTmrTbl[0];
    OSTmrSem            = OSSemCreate(1u);
    OSTmrSemSignal      = OSSemCreate(0u);


    OSEventNameSet(OSTmrSem,       (INT8U *)(void *)"uC/OS-II TmrLock",   &err);
    OSEventNameSet(OSTmrSemSignal, (INT8U *)(void *)"uC/OS-II TmrSignal", &err);


    OSTmr_InitTask();
}












 


static  void  OSTmr_InitTask (void)
{

    INT8U  err;



#line 955 ".\\UCOS_Source\\os_tmr.c"
    (void)OSTaskCreateExt(OSTmr_Task,
                          (void *)0,                                        
                          &OSTmrTaskStk[0],                                 
                          (63u - 2u),
                          65533u,
                          &OSTmrTaskStk[128u - 1u],         
                          128u,
                          (void *)0,                                        
                          0x0001u | 0x0002u);       
#line 978 ".\\UCOS_Source\\os_tmr.c"


    OSTaskNameSet((63u - 2u), (INT8U *)(void *)"uC/OS-II Tmr", &err);

}


















 


static  void  OSTmr_Link (OS_TMR  *ptmr,
                          INT8U    type)
{
    OS_TMR       *ptmr1;
    OS_TMR_WHEEL *pspoke;
    INT16U        spoke;


    ptmr->OSTmrState = 3u;
    if (type == 1u) {                             
        ptmr->OSTmrMatch = ptmr->OSTmrPeriod + OSTmrTime;
    } else {
        if (ptmr->OSTmrDly == 0u) {
            ptmr->OSTmrMatch = ptmr->OSTmrPeriod + OSTmrTime;
        } else {
            ptmr->OSTmrMatch = ptmr->OSTmrDly    + OSTmrTime;
        }
    }
    spoke  = (INT16U)(ptmr->OSTmrMatch % 7u);
    pspoke = &OSTmrWheelTbl[spoke];

    if (pspoke->OSTmrFirst == (OS_TMR *)0) {                        
        pspoke->OSTmrFirst   = ptmr;
        ptmr->OSTmrNext      = (OS_TMR *)0;
        pspoke->OSTmrEntries = 1u;
    } else {
        ptmr1                = pspoke->OSTmrFirst;                  
        pspoke->OSTmrFirst   = ptmr;
        ptmr->OSTmrNext      = (void *)ptmr1;
        ptmr1->OSTmrPrev     = (void *)ptmr;
        pspoke->OSTmrEntries++;
    }
    ptmr->OSTmrPrev = (void *)0;                                    
}













 


static  void  OSTmr_Unlink (OS_TMR *ptmr)
{
    OS_TMR        *ptmr1;
    OS_TMR        *ptmr2;
    OS_TMR_WHEEL  *pspoke;
    INT16U         spoke;


    spoke  = (INT16U)(ptmr->OSTmrMatch % 7u);
    pspoke = &OSTmrWheelTbl[spoke];

    if (pspoke->OSTmrFirst == ptmr) {                        
        ptmr1              = (OS_TMR *)ptmr->OSTmrNext;
        pspoke->OSTmrFirst = (OS_TMR *)ptmr1;
        if (ptmr1 != (OS_TMR *)0) {
            ptmr1->OSTmrPrev = (void *)0;
        }
    } else {
        ptmr1            = (OS_TMR *)ptmr->OSTmrPrev;        
        ptmr2            = (OS_TMR *)ptmr->OSTmrNext;
        ptmr1->OSTmrNext = ptmr2;
        if (ptmr2 != (OS_TMR *)0) {
            ptmr2->OSTmrPrev = (void *)ptmr1;
        }
    }
    ptmr->OSTmrState = 1u;
    ptmr->OSTmrNext  = (void *)0;
    ptmr->OSTmrPrev  = (void *)0;
    pspoke->OSTmrEntries--;
}













 


static  void  OSTmr_Task (void *p_arg)
{
    INT8U            err;
    OS_TMR          *ptmr;
    OS_TMR          *ptmr_next;
    OS_TMR_CALLBACK  pfnct;
    OS_TMR_WHEEL    *pspoke;
    INT16U           spoke;


    p_arg = p_arg;                                                
    for (;;) {
        OSSemPend(OSTmrSemSignal, 0u, &err);                      
        OSSchedLock();
        OSTmrTime++;                                              
        spoke  = (INT16U)(OSTmrTime % 7u);     
        pspoke = &OSTmrWheelTbl[spoke];
        ptmr   = pspoke->OSTmrFirst;
        while (ptmr != (OS_TMR *)0) {
            ptmr_next = (OS_TMR *)ptmr->OSTmrNext;                
                                                                  
            if (OSTmrTime == ptmr->OSTmrMatch) {                  
                ;
                OSTmr_Unlink(ptmr);                               
                if (ptmr->OSTmrOpt == 2u) {
                    OSTmr_Link(ptmr, 1u);       
                } else {
                    ptmr->OSTmrState = 2u;    
                }
                pfnct = ptmr->OSTmrCallback;                      
                if (pfnct != (OS_TMR_CALLBACK)0) {
                    (*pfnct)((void *)ptmr, ptmr->OSTmrCallbackArg);
                }
            }
            ptmr = ptmr_next;
        }
        OSSchedUnlock();
    }
}
#line 40 "UCOS_Source\\ucos_ii.c"
