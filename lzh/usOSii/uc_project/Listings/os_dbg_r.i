#line 1 "UCOS_Source\\os_dbg_r.c"














 










 



#line 1 ".\\UCOS_Source\\ucos_ii.h"














 






 












 







 

#line 1 ".\\UCOS_CFG\\app_cfg.h"



#line 46 ".\\UCOS_Source\\ucos_ii.h"
#line 1 ".\\UCOS_CFG\\os_cfg.h"














 










 





                                        











                                        















                                        





                                        
#line 79 ".\\UCOS_CFG\\os_cfg.h"


                                        
#line 89 ".\\UCOS_CFG\\os_cfg.h"


                                        
#line 99 ".\\UCOS_CFG\\os_cfg.h"


                                        





                                        






                                        
#line 124 ".\\UCOS_CFG\\os_cfg.h"


                                        
#line 133 ".\\UCOS_CFG\\os_cfg.h"


                                        






                                        








                                        






 



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





















 












 









 

extern  OS_STK   OS_CPU_ExceptStk[128u];
extern  OS_STK  *OS_CPU_ExceptStkBase;





 


OS_CPU_SR  OS_CPU_SR_Save(void);
void       OS_CPU_SR_Restore(OS_CPU_SR cpu_sr);


void  OSCtxSw              (void);
void  OSIntCtxSw           (void);
void  OSStartHighRdy       (void);

void  OS_CPU_PendSVHandler (void);

                                                   

void  OS_CPU_SysTickHandler(void);
void  OS_CPU_SysTickInit   (INT32U  cnts);

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






 

#line 669 ".\\UCOS_Source\\ucos_ii.h"






 

#line 684 ".\\UCOS_Source\\ucos_ii.h"





 

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


#line 777 ".\\UCOS_Source\\ucos_ii.h"

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





 

#line 1266 ".\\UCOS_Source\\ucos_ii.h"





 

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








 

#line 1447 ".\\UCOS_Source\\ucos_ii.h"







 


















 





 

#line 1491 ".\\UCOS_Source\\ucos_ii.h"






























 

#line 1529 ".\\UCOS_Source\\ucos_ii.h"


























 

#line 1567 ".\\UCOS_Source\\ucos_ii.h"














 

#line 1589 ".\\UCOS_Source\\ucos_ii.h"














 

#line 1615 ".\\UCOS_Source\\ucos_ii.h"






































 

#line 1661 ".\\UCOS_Source\\ucos_ii.h"






















 

#line 1691 ".\\UCOS_Source\\ucos_ii.h"



































#line 1733 ".\\UCOS_Source\\ucos_ii.h"

















#line 1757 ".\\UCOS_Source\\ucos_ii.h"





 





















 

#line 1830 ".\\UCOS_Source\\ucos_ii.h"






 


























#line 1870 ".\\UCOS_Source\\ucos_ii.h"



































 

#line 1982 ".\\UCOS_Source\\ucos_ii.h"





#line 31 "UCOS_Source\\os_dbg_r.c"





 

INT16U  const  OSDebugEn             = 1u;              



INT32U  const  OSEndiannessTest      = 0x12345678uL;             

INT16U  const  OSEventEn             = (((1u > 0u) && (4u > 0u)) || (1u > 0u) || (1u > 0u) || (1u > 0u));
INT16U  const  OSEventMax            = 10u;            
INT16U  const  OSEventNameEn         = 1u;

INT16U  const  OSEventSize           = sizeof(OS_EVENT);         
INT16U  const  OSEventTblSize        = sizeof(OSEventTbl);       




INT16U  const  OSEventMultiEn        = 1u;


INT16U  const  OSFlagEn              = 1u;

INT16U  const  OSFlagGrpSize         = sizeof(OS_FLAG_GRP);      
INT16U  const  OSFlagNodeSize        = sizeof(OS_FLAG_NODE);     
INT16U  const  OSFlagWidth           = sizeof(OS_FLAGS);         





INT16U  const  OSFlagMax             = 5u;
INT16U  const  OSFlagNameEn          = 1u;

INT16U  const  OSLowestPrio          = 63u;

INT16U  const  OSMboxEn              = 1u;

INT16U  const  OSMemEn               = 1u;
INT16U  const  OSMemMax              = 5u;          
INT16U  const  OSMemNameEn           = 1u;

INT16U  const  OSMemSize             = sizeof(OS_MEM);           
INT16U  const  OSMemTblSize          = sizeof(OSMemTbl);




INT16U  const  OSMutexEn             = 1u;

INT16U  const  OSPtrSize             = sizeof(void *);           

INT16U  const  OSQEn                 = 1u;
INT16U  const  OSQMax                = 4u;                

INT16U  const  OSQSize               = sizeof(OS_Q);             




INT16U  const  OSRdyTblSize          = ((63u) / 8u + 1u);          

INT16U  const  OSSemEn               = 1u;

INT16U  const  OSStkWidth            = sizeof(OS_STK);           

INT16U  const  OSTaskCreateEn        = 1u;
INT16U  const  OSTaskCreateExtEn     = 1u;
INT16U  const  OSTaskDelEn           = 1u;
INT16U  const  OSTaskIdleStkSize     = 128u;
INT16U  const  OSTaskProfileEn       = 1u;
INT16U  const  OSTaskMax             = 20u + 2u;  
INT16U  const  OSTaskNameEn          = 1u;
INT16U  const  OSTaskStatEn          = 1u;
INT16U  const  OSTaskStatStkSize     = 128u;
INT16U  const  OSTaskStatStkChkEn    = 1u;
INT16U  const  OSTaskSwHookEn        = 1u;
INT16U  const  OSTaskRegTblSize      = 1u;

INT16U  const  OSTCBPrioTblMax       = 63u + 1u;      
INT16U  const  OSTCBSize             = sizeof(OS_TCB);           
INT16U  const  OSTicksPerSec         = 1000u;
INT16U  const  OSTimeTickHookEn      = 1u;
INT16U  const  OSVersionNbr          = 29300u;





INT16U  const  OS_TLS_TblSize        = 0u;



INT16U  const  OSTmrEn               = 0u;
INT16U  const  OSTmrCfgMax           = 16u;
INT16U  const  OSTmrCfgNameEn        = 1u;
INT16U  const  OSTmrCfgWheelSize     = 7u;
INT16U  const  OSTmrCfgTicksPerSec   = 10u;

#line 141 "UCOS_Source\\os_dbg_r.c"
INT16U  const  OSTmrSize             = 0u;
INT16U  const  OSTmrTblSize          = 0u;
INT16U  const  OSTmrWheelSize        = 0u;
INT16U  const  OSTmrWheelTblSize     = 0u;










 


INT16U  const  OSDataSize = sizeof(OSCtxSwCtr)

                          + sizeof(OSEventFreeList)
                          + sizeof(OSEventTbl)



                          + sizeof(OSFlagTbl)
                          + sizeof(OSFlagFreeList)



                          + sizeof(OSCPUUsage)
                          + sizeof(OSIdleCtrMax)
                          + sizeof(OSIdleCtrRun)
                          + sizeof(OSStatRdy)
                          + sizeof(OSTaskStatStk)



                          + sizeof(OSTickStepState)



                          + sizeof(OSMemFreeList)
                          + sizeof(OSMemTbl)







                          + sizeof(OSQFreeList)
                          + sizeof(OSQTbl)



                          + sizeof(OSTaskRegNextAvailID)



                          + sizeof(OSTime)


#line 214 "UCOS_Source\\os_dbg_r.c"
                          + sizeof(OSIntNesting)
                          + sizeof(OSLockNesting)
                          + sizeof(OSPrioCur)
                          + sizeof(OSPrioHighRdy)
                          + sizeof(OSRdyGrp)
                          + sizeof(OSRdyTbl)
                          + sizeof(OSRunning)
                          + sizeof(OSTaskCtr)
                          + sizeof(OSIdleCtr)
                          + sizeof(OSTaskIdleStk)
                          + sizeof(OSTCBCur)
                          + sizeof(OSTCBFreeList)
                          + sizeof(OSTCBHighRdy)
                          + sizeof(OSTCBList)
                          + sizeof(OSTCBPrioTbl)
                          + sizeof(OSTCBTbl);






















 


void  OSDebugInit (void)
{
    void  const  *ptemp;


    ptemp = (void const *)&OSDebugEn;

    ptemp = (void const *)&OSEndiannessTest;

    ptemp = (void const *)&OSEventMax;
    ptemp = (void const *)&OSEventNameEn;
    ptemp = (void const *)&OSEventEn;
    ptemp = (void const *)&OSEventSize;
    ptemp = (void const *)&OSEventTblSize;
    ptemp = (void const *)&OSEventMultiEn;

    ptemp = (void const *)&OSFlagEn;
    ptemp = (void const *)&OSFlagGrpSize;
    ptemp = (void const *)&OSFlagNodeSize;
    ptemp = (void const *)&OSFlagWidth;
    ptemp = (void const *)&OSFlagMax;
    ptemp = (void const *)&OSFlagNameEn;

    ptemp = (void const *)&OSLowestPrio;

    ptemp = (void const *)&OSMboxEn;

    ptemp = (void const *)&OSMemEn;
    ptemp = (void const *)&OSMemMax;
    ptemp = (void const *)&OSMemNameEn;
    ptemp = (void const *)&OSMemSize;
    ptemp = (void const *)&OSMemTblSize;

    ptemp = (void const *)&OSMutexEn;

    ptemp = (void const *)&OSPtrSize;

    ptemp = (void const *)&OSQEn;
    ptemp = (void const *)&OSQMax;
    ptemp = (void const *)&OSQSize;

    ptemp = (void const *)&OSRdyTblSize;

    ptemp = (void const *)&OSSemEn;

    ptemp = (void const *)&OSStkWidth;

    ptemp = (void const *)&OSTaskCreateEn;
    ptemp = (void const *)&OSTaskCreateExtEn;
    ptemp = (void const *)&OSTaskDelEn;
    ptemp = (void const *)&OSTaskIdleStkSize;
    ptemp = (void const *)&OSTaskProfileEn;
    ptemp = (void const *)&OSTaskMax;
    ptemp = (void const *)&OSTaskNameEn;
    ptemp = (void const *)&OSTaskStatEn;
    ptemp = (void const *)&OSTaskStatStkSize;
    ptemp = (void const *)&OSTaskStatStkChkEn;
    ptemp = (void const *)&OSTaskSwHookEn;

    ptemp = (void const *)&OSTCBPrioTblMax;
    ptemp = (void const *)&OSTCBSize;

    ptemp = (void const *)&OSTicksPerSec;
    ptemp = (void const *)&OSTimeTickHookEn;

#line 335 "UCOS_Source\\os_dbg_r.c"

    ptemp = (void const *)&OSVersionNbr;

    ptemp = (void const *)&OSDataSize;

    ptemp = ptemp;                              
}
