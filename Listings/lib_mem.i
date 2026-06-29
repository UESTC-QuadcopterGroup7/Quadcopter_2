#line 1 "ucLib\\lib_mem.c"














 
























 





 

#line 1 "ucLib\\lib_mem.h"














 





























 








 








































 

#line 1 ".\\ucCPU\\cpu.h"














 














 









 




































 

#line 1 ".\\ucCPU\\cpu_def.h"














 









 









 






























 






















 

                                                         






                                                         
















 

                                                         












































































 

                                                         












 

#line 80 ".\\ucCPU\\cpu.h"
#line 1 ".\\ucCPU\\cpu_cfg.h"







 












 












 












 














 

 


#line 81 ".\\ucCPU\\cpu.h"
































 

typedef            void        CPU_VOID;
typedef            char        CPU_CHAR;                         
typedef  unsigned  char        CPU_BOOLEAN;                      
typedef  unsigned  char        CPU_INT08U;                       
typedef    signed  char        CPU_INT08S;                       
typedef  unsigned  short       CPU_INT16U;                       
typedef    signed  short       CPU_INT16S;                       
typedef  unsigned  int         CPU_INT32U;                       
typedef    signed  int         CPU_INT32S;                       
typedef  unsigned  long  long  CPU_INT64U;                       
typedef    signed  long  long  CPU_INT64S;                       

typedef            float       CPU_FP32;                         
typedef            double      CPU_FP64;                         


typedef  volatile  CPU_INT08U  CPU_REG08;                        
typedef  volatile  CPU_INT16U  CPU_REG16;                        
typedef  volatile  CPU_INT32U  CPU_REG32;                        
typedef  volatile  CPU_INT64U  CPU_REG64;                        


typedef            void      (*CPU_FNCT_VOID)(void);             
typedef            void      (*CPU_FNCT_PTR )(void *p_obj);      





















 

                                                                 











 

                                                                 

typedef  CPU_INT32U  CPU_ADDR;






                                                                 

typedef  CPU_INT32U  CPU_DATA;







typedef  CPU_DATA    CPU_ALIGN;                                  
typedef  CPU_ADDR    CPU_SIZE_T;                                 


















 





typedef  CPU_INT32U               CPU_STK;                       
typedef  CPU_ADDR                 CPU_STK_SIZE;                  








































































 
                                                                 


typedef  CPU_INT32U                 CPU_SR;                      

                                                                 





                                                                 




#line 323 ".\\ucCPU\\cpu.h"


















 




























 

                                                                 


                                                                 







 

void        CPU_IntDis       (void);
void        CPU_IntEn        (void);

void        CPU_IntSrcDis    (CPU_INT08U  pos);
void        CPU_IntSrcEn     (CPU_INT08U  pos);
void        CPU_IntSrcPendClr(CPU_INT08U  pos);
CPU_INT16S  CPU_IntSrcPrioGet(CPU_INT08U  pos);
void        CPU_IntSrcPrioSet(CPU_INT08U  pos,
                              CPU_INT08U  prio,
                              CPU_INT08U  type);


CPU_SR      CPU_SR_Save      (CPU_SR      new_basepri);
void        CPU_SR_Restore   (CPU_SR      cpu_sr);


void        CPU_WaitForInt   (void);
void        CPU_WaitForExcept(void);


CPU_DATA    CPU_RevBits      (CPU_DATA    val);

void        CPU_BitBandClr   (CPU_ADDR    addr,
                              CPU_INT08U  bit_nbr);
void        CPU_BitBandSet   (CPU_ADDR    addr,
                              CPU_INT08U  bit_nbr);






 

#line 436 ".\\ucCPU\\cpu.h"






 









 
                                                                                 





                                                                                 
#line 466 ".\\ucCPU\\cpu.h"

                                                                                 
#line 485 ".\\ucCPU\\cpu.h"

                                                                                 




                                                                                 
#line 505 ".\\ucCPU\\cpu.h"

                                                                                 






                                                                                 
#line 520 ".\\ucCPU\\cpu.h"






 

                                                                 





                                                                 



                                                                 
#line 547 ".\\ucCPU\\cpu.h"

                                                                 


                                                                 





                                                                 




                                                                 
#line 569 ".\\ucCPU\\cpu.h"

                                                                 
#line 585 ".\\ucCPU\\cpu.h"

                                                                 
#line 604 ".\\ucCPU\\cpu.h"

                                                                 




                                                                 






                                                                 








 








 

#line 654 ".\\ucCPU\\cpu.h"


#line 673 ".\\ucCPU\\cpu.h"


#line 692 ".\\ucCPU\\cpu.h"











#line 714 ".\\ucCPU\\cpu.h"




#line 729 ".\\ucCPU\\cpu.h"




#line 747 ".\\ucCPU\\cpu.h"








 





#line 98 "ucLib\\lib_mem.h"
#line 1 ".\\ucCPU\\cpu_core.h"














 














 









 









 











































 

#line 97 ".\\ucCPU\\cpu_core.h"
#line 1 ".\\ucLib\\lib_def.h"














 






























 








 






























 
































 

#line 122 ".\\ucLib\\lib_def.h"
#line 123 ".\\ucLib\\lib_def.h"






 




                                                                 

























                                                                 


#line 171 ".\\ucLib\\lib_def.h"

#line 180 ".\\ucLib\\lib_def.h"

#line 189 ".\\ucLib\\lib_def.h"

#line 206 ".\\ucLib\\lib_def.h"

#line 215 ".\\ucLib\\lib_def.h"

#line 224 ".\\ucLib\\lib_def.h"

#line 233 ".\\ucLib\\lib_def.h"


                                                                 



                                                                 












                                                                 






                                                                 















































































                                                                 





#line 378 ".\\ucLib\\lib_def.h"















#line 415 ".\\ucLib\\lib_def.h"


                                                                 















#line 439 ".\\ucLib\\lib_def.h"












 

typedef enum lib_err {

    LIB_ERR_NONE                            =         0u,

    LIB_MEM_ERR_NONE                        =     10000u,
    LIB_MEM_ERR_NULL_PTR                    =     10001u,        

    LIB_MEM_ERR_INVALID_MEM_SIZE            =     10100u,        
    LIB_MEM_ERR_INVALID_MEM_ALIGN           =     10101u,        
    LIB_MEM_ERR_INVALID_SEG_SIZE            =     10110u,        
    LIB_MEM_ERR_INVALID_SEG_OVERLAP         =     10111u,        
    LIB_MEM_ERR_INVALID_SEG_EXISTS          =     10112u,        
    LIB_MEM_ERR_INVALID_POOL                =     10120u,        
    LIB_MEM_ERR_INVALID_BLK_NBR             =     10130u,        
    LIB_MEM_ERR_INVALID_BLK_SIZE            =     10131u,        
    LIB_MEM_ERR_INVALID_BLK_ALIGN           =     10132u,        
    LIB_MEM_ERR_INVALID_BLK_IX              =     10133u,        
    LIB_MEM_ERR_INVALID_BLK_ADDR            =     10135u,        
    LIB_MEM_ERR_INVALID_BLK_ADDR_IN_POOL    =     10136u,        

    LIB_MEM_ERR_SEG_EMPTY                   =     10200u,        
    LIB_MEM_ERR_SEG_OVF                     =     10201u,        
    LIB_MEM_ERR_POOL_FULL                   =     10205u,        
    LIB_MEM_ERR_POOL_EMPTY                  =     10206u,        
    LIB_MEM_ERR_POOL_UNLIMITED              =     10207u,        

    LIB_MEM_ERR_HEAP_EMPTY                  =     10210u,        
    LIB_MEM_ERR_HEAP_OVF                    =     10211u,        
    LIB_MEM_ERR_HEAP_NOT_FOUND              =     10215u,        

    LIB_MEM_ERR_ADDR_OVF                    =     10300u         
} LIB_ERR;






 






 






 

                                                                 





















 


















 



























 































 

























 









































 




























 


































 






















 


























 


























 

#line 838 ".\\ucLib\\lib_def.h"






#line 850 ".\\ucLib\\lib_def.h"


















 
























 






















 
























 
























 

























 

























 






















 








 











































 
















































 




















































 























 

#line 1241 ".\\ucLib\\lib_def.h"






#line 1253 ".\\ucLib\\lib_def.h"












 

















 


















 


















 








 






 






 

                                                                 











 

#line 98 ".\\ucCPU\\cpu_core.h"
#line 99 ".\\ucCPU\\cpu_core.h"

#line 1 ".\\ucLib\\lib_mem.h"














 





























 








 

#line 102 ".\\ucCPU\\cpu_core.h"
#line 1 ".\\ucLib\\lib_str.h"














 
























 








 












 

































 














































 

#line 146 ".\\ucLib\\lib_str.h"

#line 148 ".\\ucLib\\lib_str.h"
#line 1 ".\\ucLib\\lib_ascii.h"














 
















































 








 



































 

#line 112 ".\\ucLib\\lib_ascii.h"
#line 113 ".\\ucLib\\lib_ascii.h"






 












 





 

                                                                 
#line 173 ".\\ucLib\\lib_ascii.h"

#line 219 ".\\ucLib\\lib_ascii.h"


                                                                 
#line 238 ".\\ucLib\\lib_ascii.h"





                                                                 
#line 254 ".\\ucLib\\lib_ascii.h"

#line 265 ".\\ucLib\\lib_ascii.h"


                                                                 
#line 275 ".\\ucLib\\lib_ascii.h"




                                                                 
#line 306 ".\\ucLib\\lib_ascii.h"


                                                                 
#line 315 ".\\ucLib\\lib_ascii.h"





                                                                 
#line 347 ".\\ucLib\\lib_ascii.h"


                                                                 









                                                                 









 






 






 









 


















 




















 





















 























 





















 





















 






















 

























 

























 



























 

























 





















 




























 









 


























 





























 








 

CPU_BOOLEAN  ASCII_IsAlpha   (CPU_CHAR  c);

CPU_BOOLEAN  ASCII_IsAlphaNum(CPU_CHAR  c);

CPU_BOOLEAN  ASCII_IsLower   (CPU_CHAR  c);

CPU_BOOLEAN  ASCII_IsUpper   (CPU_CHAR  c);

CPU_BOOLEAN  ASCII_IsDig     (CPU_CHAR  c);

CPU_BOOLEAN  ASCII_IsDigOct  (CPU_CHAR  c);

CPU_BOOLEAN  ASCII_IsDigHex  (CPU_CHAR  c);

CPU_BOOLEAN  ASCII_IsBlank   (CPU_CHAR  c);

CPU_BOOLEAN  ASCII_IsSpace   (CPU_CHAR  c);

CPU_BOOLEAN  ASCII_IsPrint   (CPU_CHAR  c);

CPU_BOOLEAN  ASCII_IsGraph   (CPU_CHAR  c);

CPU_BOOLEAN  ASCII_IsPunct   (CPU_CHAR  c);

CPU_BOOLEAN  ASCII_IsCtrl    (CPU_CHAR  c);


CPU_CHAR     ASCII_ToLower   (CPU_CHAR  c);

CPU_CHAR     ASCII_ToUpper   (CPU_CHAR  c);


CPU_BOOLEAN  ASCII_Cmp       (CPU_CHAR  c1,
                              CPU_CHAR  c2);






 








 

#line 149 ".\\ucLib\\lib_str.h"

#line 1 ".\\ucLib\\lib_cfg.h"












 











 





 











 














 

                                                                 
                                                                 
                                                                 
                                                                 









 

                                                                 
                                                                 
                                                                 





















 

                                                                 
                                                                 
                                                                 



                                                                 
                                                                 
                                                                 



                                                                 
                                                                 
                                                                 













 












 

                                                                 
                                                                 



                                                                 
                                                                 
                                                                 
                                                                 







 

#line 151 ".\\ucLib\\lib_str.h"










 












 












 

                                                                 






                                                                 
                                                                 









 
















 






 






 












 

                                                                 








 

                                                                 
CPU_SIZE_T   Str_Len            (const  CPU_CHAR      *pstr);

CPU_SIZE_T   Str_Len_N          (const  CPU_CHAR      *pstr,
                                        CPU_SIZE_T     len_max);


                                                                        
CPU_CHAR    *Str_Copy           (       CPU_CHAR      *pstr_dest,
                                 const  CPU_CHAR      *pstr_src);

CPU_CHAR    *Str_Copy_N         (       CPU_CHAR      *pstr_dest,
                                 const  CPU_CHAR      *pstr_src,
                                        CPU_SIZE_T     len_max);


CPU_CHAR    *Str_Cat            (       CPU_CHAR      *pstr_dest,
                                 const  CPU_CHAR      *pstr_cat);

CPU_CHAR    *Str_Cat_N          (       CPU_CHAR      *pstr_dest,
                                 const  CPU_CHAR      *pstr_cat,
                                        CPU_SIZE_T     len_max);


                                                                        
CPU_INT16S   Str_Cmp            (const  CPU_CHAR      *p1_str,
                                 const  CPU_CHAR      *p2_str);

CPU_INT16S   Str_Cmp_N          (const  CPU_CHAR      *p1_str,
                                 const  CPU_CHAR      *p2_str,
                                        CPU_SIZE_T     len_max);

CPU_INT16S   Str_CmpIgnoreCase  (const  CPU_CHAR      *p1_str,
                                 const  CPU_CHAR      *p2_str);

CPU_INT16S   Str_CmpIgnoreCase_N(const  CPU_CHAR      *p1_str,
                                 const  CPU_CHAR      *p2_str,
                                        CPU_SIZE_T     len_max);


                                                                        
CPU_CHAR    *Str_Char           (const  CPU_CHAR      *pstr,
                                        CPU_CHAR       srch_char);

CPU_CHAR    *Str_Char_N         (const  CPU_CHAR      *pstr,
                                        CPU_SIZE_T     len_max,
                                        CPU_CHAR       srch_char);

CPU_CHAR    *Str_Char_Last      (const  CPU_CHAR      *pstr,
                                        CPU_CHAR       srch_char);

CPU_CHAR    *Str_Char_Last_N    (const  CPU_CHAR      *pstr,
                                        CPU_SIZE_T     len_max,
                                        CPU_CHAR       srch_char);

CPU_CHAR    *Str_Char_Replace   (       CPU_CHAR      *pstr,
                                        CPU_CHAR       char_srch,
                                        CPU_CHAR       char_replace);

CPU_CHAR    *Str_Char_Replace_N (       CPU_CHAR      *pstr,
                                        CPU_CHAR       char_srch,
                                        CPU_CHAR       char_replace,
                                        CPU_SIZE_T     len_max);

CPU_CHAR    *Str_Str            (const  CPU_CHAR      *pstr,
                                 const  CPU_CHAR      *pstr_srch);

CPU_CHAR    *Str_Str_N          (const  CPU_CHAR      *pstr,
                                 const  CPU_CHAR      *pstr_srch,
                                        CPU_SIZE_T     len_max);


                                                                        
CPU_CHAR    *Str_FmtNbr_Int32U  (       CPU_INT32U     nbr,
                                        CPU_INT08U     nbr_dig,
                                        CPU_INT08U     nbr_base,
                                        CPU_CHAR       lead_char,
                                        CPU_BOOLEAN    lower_case,
                                        CPU_BOOLEAN    nul,
                                        CPU_CHAR      *pstr);

CPU_CHAR    *Str_FmtNbr_Int32S  (       CPU_INT32S     nbr,
                                        CPU_INT08U     nbr_dig,
                                        CPU_INT08U     nbr_base,
                                        CPU_CHAR       lead_char,
                                        CPU_BOOLEAN    lower_case,
                                        CPU_BOOLEAN    nul,
                                        CPU_CHAR      *pstr);

#line 361 ".\\ucLib\\lib_str.h"


                                                                        
CPU_INT32U   Str_ParseNbr_Int32U(const  CPU_CHAR      *pstr,
                                        CPU_CHAR     **pstr_next,
                                        CPU_INT08U     nbr_base);

CPU_INT32S   Str_ParseNbr_Int32S(const  CPU_CHAR      *pstr,
                                        CPU_CHAR     **pstr_next,
                                        CPU_INT08U     nbr_base);






 

#line 407 ".\\ucLib\\lib_str.h"








 

#line 103 ".\\ucCPU\\cpu_core.h"





















 






#line 137 ".\\ucCPU\\cpu_core.h"

#line 144 ".\\ucCPU\\cpu_core.h"

#line 151 ".\\ucCPU\\cpu_core.h"









 










 









 






 

typedef enum cpu_err {

    CPU_ERR_NONE                            =         0u,
    CPU_ERR_NULL_PTR                        =        10u,

    CPU_ERR_NAME_SIZE                       =      1000u,

    CPU_ERR_TS_FREQ_INVALID                 =      2000u

} CPU_ERR;









 

typedef  CPU_INT32U  CPU_TS32;
typedef  CPU_INT64U  CPU_TS64;

typedef  CPU_TS32    CPU_TS;                                     


#line 228 ".\\ucCPU\\cpu_core.h"






 

typedef  CPU_INT32U  CPU_TS_TMR_FREQ;






 


extern  CPU_CHAR         CPU_Name[32u];      




















#line 277 ".\\ucCPU\\cpu_core.h"






 











































































































 




















 












































 

#line 466 ".\\ucCPU\\cpu_core.h"

#line 473 ".\\ucCPU\\cpu_core.h"


#line 488 ".\\ucCPU\\cpu_core.h"

























 

void             CPU_Init                 (void);

void             CPU_SW_Exception         (void);




void             CPU_NameClr              (void);

void             CPU_NameGet              (       CPU_CHAR  *p_name,
                                                  CPU_ERR   *p_err);

void             CPU_NameSet              (const  CPU_CHAR  *p_name,
                                                  CPU_ERR   *p_err);




                                                                         





















#line 568 ".\\ucCPU\\cpu_core.h"



                                                                         






CPU_DATA         CPU_CntLeadZeros         (CPU_DATA    val);








CPU_DATA         CPU_CntLeadZeros08       (CPU_INT08U  val);


CPU_DATA         CPU_CntLeadZeros16       (CPU_INT16U  val);


CPU_DATA         CPU_CntLeadZeros32       (CPU_INT32U  val);


CPU_DATA         CPU_CntLeadZeros64       (CPU_INT64U  val);









CPU_DATA         CPU_CntTrailZeros        (CPU_DATA    val);








CPU_DATA         CPU_CntTrailZeros08      (CPU_INT08U  val);


CPU_DATA         CPU_CntTrailZeros16      (CPU_INT16U  val);


CPU_DATA         CPU_CntTrailZeros32      (CPU_INT32U  val);


CPU_DATA         CPU_CntTrailZeros64      (CPU_INT64U  val);


CPU_INT08U       CPU_PopCnt32             (CPU_INT32U  value);

                                                                         










 














































 













































































 






















































 














 

#line 850 ".\\ucCPU\\cpu_core.h"

#line 863 ".\\ucCPU\\cpu_core.h"






#line 881 ".\\ucCPU\\cpu_core.h"


#line 895 ".\\ucCPU\\cpu_core.h"

                                                                 
#line 909 ".\\ucCPU\\cpu_core.h"


                                                                 
#line 945 ".\\ucCPU\\cpu_core.h"








#line 970 ".\\ucCPU\\cpu_core.h"






















 


















 

                                                                 











 

#line 99 "ucLib\\lib_mem.h"

#line 101 "ucLib\\lib_mem.h"
#line 102 "ucLib\\lib_mem.h"






 












 










 














 

                                                                 














 

                                                                 














 













 










 








 

typedef  CPU_INT32U  LIB_MEM_TYPE;






 

typedef  CPU_SIZE_T  MEM_POOL_BLK_QTY;






 

typedef  MEM_POOL_BLK_QTY  MEM_POOL_IX;






 

#line 253 "ucLib\\lib_mem.h"






 

typedef  struct  mem_seg  MEM_SEG;                               

struct mem_seg {
           CPU_ADDR         AddrBase;                            
           CPU_ADDR         AddrEnd;                             
           CPU_ADDR         AddrNext;                            

           MEM_SEG         *NextPtr;                             

           CPU_SIZE_T       PaddingAlign;                        





};

typedef  struct  mem_seg_info {                                  
    CPU_SIZE_T  UsedSize;                                        
    CPU_SIZE_T  TotalSize;                                       

    CPU_ADDR    AddrBase;
    CPU_ADDR    AddrNextAlloc;                                   
} MEM_SEG_INFO;
























 

                                                                 
typedef  struct  mem_pool {
    void               *PoolAddrStart;                           
    void               *PoolAddrEnd;                             
    MEM_POOL_BLK_QTY    BlkNbr;                                  
    CPU_SIZE_T          BlkSize;                                 
    void              **BlkFreeTbl;                              
    CPU_SIZE_T          BlkFreeTblIx;                            
} MEM_POOL;























 

typedef  struct  mem_dyn_pool {                                  
           MEM_SEG     *PoolSegPtr;                              
           CPU_SIZE_T   BlkSize;                                 
           CPU_SIZE_T   BlkAlign;                                
           CPU_SIZE_T   BlkPaddingAlign;                         
           void        *BlkFreePtr;                              

           CPU_SIZE_T   BlkQtyMax;                               
           CPU_SIZE_T   BlkAllocCnt;                             




} MEM_DYN_POOL;






 






 























 
















































 












#line 474 "ucLib\\lib_mem.h"







#line 489 "ucLib\\lib_mem.h"






#line 501 "ucLib\\lib_mem.h"

























































 

































#line 600 "ucLib\\lib_mem.h"






#line 612 "ucLib\\lib_mem.h"




















































 

































#line 706 "ucLib\\lib_mem.h"






#line 718 "ucLib\\lib_mem.h"






























































 

#line 844 "ucLib\\lib_mem.h"













#line 863 "ucLib\\lib_mem.h"

#line 871 "ucLib\\lib_mem.h"












#line 889 "ucLib\\lib_mem.h"

#line 897 "ucLib\\lib_mem.h"








#line 911 "ucLib\\lib_mem.h"









































































 

#line 1018 "ucLib\\lib_mem.h"


#line 1032 "ucLib\\lib_mem.h"


#line 1041 "ucLib\\lib_mem.h"







#line 1054 "ucLib\\lib_mem.h"
























































 

                                                                 










































































 

                                                                 



















































 












#line 1260 "ucLib\\lib_mem.h"

#line 1268 "ucLib\\lib_mem.h"

#line 1277 "ucLib\\lib_mem.h"






 

void               Mem_Init                 (       void);

                                                                 
void               Mem_Clr                  (       void              *pmem,
                                                    CPU_SIZE_T         size);

void               Mem_Set                  (       void              *pmem,
                                                    CPU_INT08U         data_val,
                                                    CPU_SIZE_T         size);

void               Mem_Copy                 (       void              *pdest,
                                             const  void              *psrc,
                                                    CPU_SIZE_T         size);

void               Mem_Move                 (       void              *pdest,
                                             const  void              *psrc,
                                                    CPU_SIZE_T         size);

CPU_BOOLEAN        Mem_Cmp                  (const  void              *p1_mem,
                                             const  void              *p2_mem,
                                                    CPU_SIZE_T         size);


                                                                 

void              *Mem_HeapAlloc            (       CPU_SIZE_T         size,
                                                    CPU_SIZE_T         align,
                                                    CPU_SIZE_T        *p_bytes_reqd,
                                                    LIB_ERR           *p_err);

CPU_SIZE_T         Mem_HeapGetSizeRem       (       CPU_SIZE_T         align,
                                                    LIB_ERR           *p_err);


                                                                 
void               Mem_SegCreate            (const  CPU_CHAR          *p_name,
                                                    MEM_SEG           *p_seg,
                                                    CPU_ADDR           seg_base_addr,
                                                    CPU_SIZE_T         size,
                                                    CPU_SIZE_T         padding_align,
                                                    LIB_ERR           *p_err);

void               Mem_SegClr               (       MEM_SEG           *p_seg,
                                                    LIB_ERR           *p_err);

void              *Mem_SegAlloc             (const  CPU_CHAR          *p_name,
                                                    MEM_SEG           *p_seg,
                                                    CPU_SIZE_T         size,
                                                    LIB_ERR           *p_err);

void              *Mem_SegAllocExt          (const  CPU_CHAR          *p_name,
                                                    MEM_SEG           *p_seg,
                                                    CPU_SIZE_T         size,
                                                    CPU_SIZE_T         align,
                                                    CPU_SIZE_T        *p_bytes_reqd,
                                                    LIB_ERR           *p_err);

void              *Mem_SegAllocHW           (const  CPU_CHAR          *p_name,
                                                    MEM_SEG           *p_seg,
                                                    CPU_SIZE_T         size,
                                                    CPU_SIZE_T         align,
                                                    CPU_SIZE_T        *p_bytes_reqd,
                                                    LIB_ERR           *p_err);

CPU_SIZE_T         Mem_SegRemSizeGet        (       MEM_SEG           *p_seg,
                                                    CPU_SIZE_T         align,
                                                    MEM_SEG_INFO      *p_seg_info,
                                                    LIB_ERR           *p_err);






                                                                 
void               Mem_PoolCreate           (       MEM_POOL          *p_pool,
                                                    void              *p_mem_base,
                                                    CPU_SIZE_T         mem_size,
                                                    MEM_POOL_BLK_QTY   blk_nbr,
                                                    CPU_SIZE_T         blk_size,
                                                    CPU_SIZE_T         blk_align,
                                                    CPU_SIZE_T        *p_bytes_reqd,
                                                    LIB_ERR           *p_err);

void               Mem_PoolClr              (       MEM_POOL          *p_pool,
                                                    LIB_ERR           *p_err);

void              *Mem_PoolBlkGet           (       MEM_POOL          *p_pool,
                                                    CPU_SIZE_T         size,
                                                    LIB_ERR           *p_err);

void               Mem_PoolBlkFree          (       MEM_POOL          *p_pool,
                                                    void              *p_blk,
                                                    LIB_ERR           *p_err);

MEM_POOL_BLK_QTY   Mem_PoolBlkGetNbrAvail   (       MEM_POOL          *p_pool,
                                                    LIB_ERR           *p_err);

                                                                 
void               Mem_DynPoolCreate        (const  CPU_CHAR          *p_name,
                                                    MEM_DYN_POOL      *p_pool,
                                                    MEM_SEG           *p_seg,
                                                    CPU_SIZE_T         blk_size,
                                                    CPU_SIZE_T         blk_align,
                                                    CPU_SIZE_T         blk_qty_init,
                                                    CPU_SIZE_T         blk_qty_max,
                                                    LIB_ERR           *p_err);

void               Mem_DynPoolCreateHW      (const  CPU_CHAR          *p_name,
                                                    MEM_DYN_POOL      *p_pool,
                                                    MEM_SEG           *p_seg,
                                                    CPU_SIZE_T         blk_size,
                                                    CPU_SIZE_T         blk_align,
                                                    CPU_SIZE_T         blk_qty_init,
                                                    CPU_SIZE_T         blk_qty_max,
                                                    LIB_ERR           *p_err);

void              *Mem_DynPoolBlkGet        (       MEM_DYN_POOL      *p_pool,
                                                    LIB_ERR           *p_err);

void               Mem_DynPoolBlkFree       (       MEM_DYN_POOL      *p_pool,
                                                    void              *p_blk,
                                                    LIB_ERR           *p_err);

CPU_SIZE_T         Mem_DynPoolBlkNbrAvailGet(       MEM_DYN_POOL      *p_pool,
                                                    LIB_ERR           *p_err);






 

#line 1430 "ucLib\\lib_mem.h"



#line 1444 "ucLib\\lib_mem.h"








#line 1458 "ucLib\\lib_mem.h"


#line 1471 "ucLib\\lib_mem.h"






 

                                                                 











 

#line 51 "ucLib\\lib_mem.c"
#line 1 "ucLib\\lib_math.h"














 



































 








 



































 

#line 99 "ucLib\\lib_math.h"
#line 100 "ucLib\\lib_math.h"

#line 102 "ucLib\\lib_math.h"






 












 

































 












 





 

typedef  CPU_INT32U  RAND_NBR;






 






 

















 




















 




















 








 

void      Math_Init       (void);

                                                                 
void      Math_RandSetSeed(RAND_NBR  seed);

RAND_NBR  Math_Rand       (void);

RAND_NBR  Math_RandSeed   (RAND_NBR  seed);






 








 

#line 52 "ucLib\\lib_mem.c"
#line 53 "ucLib\\lib_mem.c"






 






 






 






 






 




CPU_INT08U   Mem_Heap[1024u];                    


MEM_SEG      Mem_SegHeap;                                        


MEM_SEG     *Mem_SegHeadPtr;                                     






 

static  void          Mem_SegCreateCritical    (const  CPU_CHAR      *p_name,
                                                       MEM_SEG       *p_seg,
                                                       CPU_ADDR       seg_base_addr,
                                                       CPU_SIZE_T     padding_align,
                                                       CPU_SIZE_T     size);


static  MEM_SEG      *Mem_SegOverlapChkCritical(       CPU_ADDR       seg_base_addr,
                                                       CPU_SIZE_T     size,
                                                       LIB_ERR       *p_err);


static  void         *Mem_SegAllocInternal     (const  CPU_CHAR      *p_name,
                                                       MEM_SEG       *p_seg,
                                                       CPU_SIZE_T     size,
                                                       CPU_SIZE_T     align,
                                                       CPU_SIZE_T     padding_align,
                                                       CPU_SIZE_T    *p_bytes_reqd,
                                                       LIB_ERR       *p_err);

static  void         *Mem_SegAllocExtCritical  (       MEM_SEG       *p_seg,
                                                       CPU_SIZE_T     size,
                                                       CPU_SIZE_T     align,
                                                       CPU_SIZE_T     padding_align,
                                                       CPU_SIZE_T    *p_bytes_reqd,
                                                       LIB_ERR       *p_err);

static  void          Mem_DynPoolCreateInternal(const  CPU_CHAR      *p_name,
                                                       MEM_DYN_POOL  *p_pool,
                                                       MEM_SEG       *p_seg,
                                                       CPU_SIZE_T     blk_size,
                                                       CPU_SIZE_T     blk_align,
                                                       CPU_SIZE_T     blk_padding_align,
                                                       CPU_SIZE_T     blk_qty_init,
                                                       CPU_SIZE_T     blk_qty_max,
                                                       LIB_ERR       *p_err);

#line 150 "ucLib\\lib_mem.c"












 







 






















 

void  Mem_Init (void)
{

                                                                 
    Mem_SegHeadPtr = 0;


    {
        LIB_ERR   err;
        CPU_ADDR  heap_base_addr;


                                                                 



        heap_base_addr = (CPU_ADDR)&Mem_Heap[0u];


        Mem_SegCreate("Heap",
                      &Mem_SegHeap,                              
                       heap_base_addr,
                       1024u,
                       1u,
                      &err);
        if (err != LIB_MEM_ERR_NONE) {
            do { CPU_SW_Exception(); } while (0);
        }
    }

}






















 

void  Mem_Clr (void        *pmem,
               CPU_SIZE_T   size)
{
    Mem_Set(pmem,
            0u,                                                  
            size);
}
































 

void  Mem_Set (void        *pmem,
               CPU_INT08U   data_val,
               CPU_SIZE_T   size)
{
    CPU_SIZE_T   size_rem;
    CPU_ALIGN    data_align;
    CPU_ALIGN   *pmem_align;
    CPU_INT08U  *pmem_08;
    CPU_DATA     mem_align_mod;
    CPU_DATA     i;


#line 311 "ucLib\\lib_mem.c"


    data_align = 0u;
    for (i = 0u; i < sizeof(CPU_ALIGN); i++) {                   
        data_align <<=  8u;
        data_align  |= (CPU_ALIGN)data_val;
    }

    size_rem      =  size;
    mem_align_mod = (CPU_INT08U)((CPU_ADDR)pmem % sizeof(CPU_ALIGN));    

    pmem_08 = (CPU_INT08U *)pmem;
    if (mem_align_mod != 0u) {                                   
        i = mem_align_mod;
        while ((size_rem > 0) &&                                 
               (i        < sizeof(CPU_ALIGN ))) {                
           *pmem_08++ = data_val;
            size_rem -= sizeof(CPU_INT08U);
            i++;
        }
    }

    pmem_align = (CPU_ALIGN *)pmem_08;                           
    while (size_rem >= sizeof(CPU_ALIGN)) {                      
       *pmem_align++ = data_align;                               
        size_rem    -= sizeof(CPU_ALIGN);
    }

    pmem_08 = (CPU_INT08U *)pmem_align;
    while (size_rem > 0) {                                       
       *pmem_08++   = data_val;
        size_rem   -= sizeof(CPU_INT08U);
    }
}



















































 


void  Mem_Copy (       void        *pdest,
                const  void        *psrc,
                       CPU_SIZE_T   size)
{
           CPU_SIZE_T    size_rem;
           CPU_SIZE_T    mem_gap_octets;
           CPU_ALIGN    *pmem_align_dest;
    const  CPU_ALIGN    *pmem_align_src;
           CPU_INT08U   *pmem_08_dest;
    const  CPU_INT08U   *pmem_08_src;
           CPU_DATA      i;
           CPU_DATA      mem_align_mod_dest;
           CPU_DATA      mem_align_mod_src;
           CPU_BOOLEAN   mem_aligned;


#line 426 "ucLib\\lib_mem.c"


    size_rem           =  size;

    pmem_08_dest       = (      CPU_INT08U *)pdest;
    pmem_08_src        = (const CPU_INT08U *)psrc;

    mem_gap_octets     = (CPU_SIZE_T)(pmem_08_src - pmem_08_dest);


    if (mem_gap_octets >= sizeof(CPU_ALIGN)) {                   
                                                                 
        mem_align_mod_dest = (CPU_INT08U)((CPU_ADDR)pmem_08_dest % sizeof(CPU_ALIGN));
        mem_align_mod_src  = (CPU_INT08U)((CPU_ADDR)pmem_08_src  % sizeof(CPU_ALIGN));

        mem_aligned        = (mem_align_mod_dest == mem_align_mod_src) ? 1u : 0u;

        if (mem_aligned == 1u) {                            
                                                                 
            if (mem_align_mod_dest != 0u) {                      
                i = mem_align_mod_dest;
                while ((size_rem   >  0) &&                      
                       (i          <  sizeof(CPU_ALIGN ))) {     
                   *pmem_08_dest++ = *pmem_08_src++;
                    size_rem      -=  sizeof(CPU_INT08U);
                    i++;
                }
            }

            pmem_align_dest = (      CPU_ALIGN *)pmem_08_dest;   
            pmem_align_src  = (const CPU_ALIGN *)pmem_08_src;
            while (size_rem      >=  sizeof(CPU_ALIGN)) {        
               *pmem_align_dest++ = *pmem_align_src++;           
                size_rem         -=  sizeof(CPU_ALIGN);
            }

            pmem_08_dest = (      CPU_INT08U *)pmem_align_dest;
            pmem_08_src  = (const CPU_INT08U *)pmem_align_src;
        }
    }

    while (size_rem > 0) {                                       
       *pmem_08_dest++ = *pmem_08_src++;                         
        size_rem      -=  sizeof(CPU_INT08U);
    }
}




































 

void  Mem_Move (       void        *pdest,
                const  void        *psrc,
                       CPU_SIZE_T   size)
{
           CPU_SIZE_T    size_rem;
           CPU_SIZE_T    mem_gap_octets;
           CPU_ALIGN    *pmem_align_dest;
    const  CPU_ALIGN    *pmem_align_src;
           CPU_INT08U   *pmem_08_dest;
    const  CPU_INT08U   *pmem_08_src;
           CPU_INT08S    i;
           CPU_DATA      mem_align_mod_dest;
           CPU_DATA      mem_align_mod_src;
           CPU_BOOLEAN   mem_aligned;


#line 537 "ucLib\\lib_mem.c"

    pmem_08_src  = (const CPU_INT08U *)psrc;
    pmem_08_dest = (      CPU_INT08U *)pdest;
    if (pmem_08_src > pmem_08_dest) {
        Mem_Copy(pdest, psrc, size);
        return;
    }

    size_rem           =  size;

    pmem_08_dest       = (      CPU_INT08U *)pdest + size - 1;
    pmem_08_src        = (const CPU_INT08U *)psrc  + size - 1;

    mem_gap_octets     = (CPU_SIZE_T)(pmem_08_dest - pmem_08_src);


    if (mem_gap_octets >= sizeof(CPU_ALIGN)) {                   

                                                                 
        mem_align_mod_dest = (CPU_INT08U)((CPU_ADDR)pmem_08_dest % sizeof(CPU_ALIGN));
        mem_align_mod_src  = (CPU_INT08U)((CPU_ADDR)pmem_08_src  % sizeof(CPU_ALIGN));

        mem_aligned        = (mem_align_mod_dest == mem_align_mod_src) ? 1u : 0u;

        if (mem_aligned == 1u) {                            
                                                                 
            if (mem_align_mod_dest != (sizeof(CPU_ALIGN) - 1)) { 
                i = (CPU_INT08S)mem_align_mod_dest;
                while ((size_rem   >  0) &&                      
                       (i          >= 0)) {                      
                   *pmem_08_dest-- = *pmem_08_src--;
                    size_rem      -=  sizeof(CPU_INT08U);
                    i--;
                }
            }

                                                                 
            pmem_align_dest = (      CPU_ALIGN *)(((CPU_INT08U *)pmem_08_dest - sizeof(CPU_ALIGN)) + 1);
            pmem_align_src  = (const CPU_ALIGN *)(((CPU_INT08U *)pmem_08_src  - sizeof(CPU_ALIGN)) + 1);
            while (size_rem      >=  sizeof(CPU_ALIGN)) {        
               *pmem_align_dest-- = *pmem_align_src--;           
                size_rem         -=  sizeof(CPU_ALIGN);
            }

            pmem_08_dest = (      CPU_INT08U *)pmem_align_dest + sizeof(CPU_ALIGN) - 1;
            pmem_08_src  = (const CPU_INT08U *)pmem_align_src  + sizeof(CPU_ALIGN) - 1;

        }
    }

    while (size_rem > 0) {                                       
       *pmem_08_dest-- = *pmem_08_src--;                         
        size_rem      -=  sizeof(CPU_INT08U);
    }
}








































 

CPU_BOOLEAN  Mem_Cmp (const  void        *p1_mem,
                      const  void        *p2_mem,
                             CPU_SIZE_T   size)
{
           CPU_SIZE_T    size_rem;
           CPU_ALIGN    *p1_mem_align;
           CPU_ALIGN    *p2_mem_align;
    const  CPU_INT08U   *p1_mem_08;
    const  CPU_INT08U   *p2_mem_08;
           CPU_DATA      i;
           CPU_DATA      mem_align_mod_1;
           CPU_DATA      mem_align_mod_2;
           CPU_BOOLEAN   mem_aligned;
           CPU_BOOLEAN   mem_cmp;


    if (size < 1) {                                              
        return (1u);
    }
    if (p1_mem == (void *)0) {
        return (0u);
    }
    if (p2_mem == (void *)0) {
        return (0u);
    }


    mem_cmp         =  1u;                                  
    size_rem        =  size;
                                                                 
    p1_mem_08       = (const CPU_INT08U *)p1_mem + size;
    p2_mem_08       = (const CPU_INT08U *)p2_mem + size;
                                                                 
    mem_align_mod_1 = (CPU_INT08U)((CPU_ADDR)p1_mem_08 % sizeof(CPU_ALIGN));
    mem_align_mod_2 = (CPU_INT08U)((CPU_ADDR)p2_mem_08 % sizeof(CPU_ALIGN));

    mem_aligned     = (mem_align_mod_1 == mem_align_mod_2) ? 1u : 0u;

    if (mem_aligned == 1u) {                                
                                                                 
        if (mem_align_mod_1 != 0u) {                             
            i = mem_align_mod_1;
            while ((mem_cmp == 1u) &&                       
                   (size_rem > 0)       &&                       
                   (i        > 0)) {                             
                p1_mem_08--;
                p2_mem_08--;
                if (*p1_mem_08 != *p2_mem_08) {                  
                     mem_cmp = 0u;
                }
                size_rem -= sizeof(CPU_INT08U);
                i--;
            }
        }

        if (mem_cmp == 1u) {                                
            p1_mem_align = (CPU_ALIGN *)p1_mem_08;               
            p2_mem_align = (CPU_ALIGN *)p2_mem_08;

            while ((mem_cmp  == 1u) &&                      
                   (size_rem >= sizeof(CPU_ALIGN))) {            
                p1_mem_align--;
                p2_mem_align--;
                if (*p1_mem_align != *p2_mem_align) {            
                     mem_cmp = 0u;
                }
                size_rem -= sizeof(CPU_ALIGN);
            }

            p1_mem_08 = (CPU_INT08U *)p1_mem_align;
            p2_mem_08 = (CPU_INT08U *)p2_mem_align;
        }
    }

    while ((mem_cmp == 1u) &&                               
           (size_rem > 0)) {                                     
        p1_mem_08--;
        p2_mem_08--;
        if (*p1_mem_08 != *p2_mem_08) {                          
             mem_cmp = 0u;
        }
        size_rem -= sizeof(CPU_INT08U);
    }

    return (mem_cmp);
}








































 


void  *Mem_HeapAlloc (CPU_SIZE_T   size,
                      CPU_SIZE_T   align,
                      CPU_SIZE_T  *p_bytes_reqd,
                      LIB_ERR     *p_err)
{
    void  *p_mem;


    p_mem = Mem_SegAllocInternal(0,
                                &Mem_SegHeap,
                                 size,
                                 align,
                                 1u,
                                 p_bytes_reqd,
                                 p_err);
    if (*p_err == LIB_MEM_ERR_SEG_OVF) {
       *p_err = LIB_MEM_ERR_HEAP_OVF;
    }

    return (p_mem);
}




























 


CPU_SIZE_T  Mem_HeapGetSizeRem (CPU_SIZE_T   align,
                                LIB_ERR     *p_err)
{
    CPU_SIZE_T  rem_size;


    rem_size = Mem_SegRemSizeGet(&Mem_SegHeap,
                                  align,
                                  0,
                                  p_err);
    if (*p_err != LIB_MEM_ERR_NONE) {
        return (0u);
    }

    return (rem_size);
}








































 

void  Mem_SegCreate (const  CPU_CHAR    *p_name,
                            MEM_SEG     *p_seg,
                            CPU_ADDR     seg_base_addr,
                            CPU_SIZE_T   size,
                            CPU_SIZE_T   padding_align,
                            LIB_ERR     *p_err)
{
    CPU_SR cpu_sr = (CPU_SR)0;


#line 909 "ucLib\\lib_mem.c"

    do { do { cpu_sr = CPU_SR_Save(1u << (8u - 4u));} while (0); } while (0);
#line 921 "ucLib\\lib_mem.c"

    Mem_SegCreateCritical(p_name,                                
                          p_seg,
                          seg_base_addr,
                          padding_align,
                          size);
    do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);

   *p_err = LIB_MEM_ERR_NONE;
}
























 


void  Mem_SegClr (MEM_SEG  *p_seg,
                  LIB_ERR  *p_err)
{
    CPU_SR cpu_sr = (CPU_SR)0;


#line 974 "ucLib\\lib_mem.c"

    do { do { cpu_sr = CPU_SR_Save(1u << (8u - 4u));} while (0); } while (0);
    p_seg->AddrNext = p_seg->AddrBase;
    do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);

   *p_err = LIB_MEM_ERR_NONE;
}































 

CPU_SIZE_T  Mem_SegRemSizeGet (MEM_SEG       *p_seg,
                               CPU_SIZE_T     align,
                               MEM_SEG_INFO  *p_seg_info,
                               LIB_ERR       *p_err)
{
    CPU_SIZE_T  rem_size;
    CPU_SIZE_T  total_size;
    CPU_SIZE_T  used_size;
    CPU_ADDR    next_addr_align;
    CPU_SR cpu_sr = (CPU_SR)0;


#line 1036 "ucLib\\lib_mem.c"

    if (p_seg == 0) {                                     

        p_seg = &Mem_SegHeap;




    }

    do { do { cpu_sr = CPU_SR_Save(1u << (8u - 4u));} while (0); } while (0);                                        
    next_addr_align = (((p_seg->AddrNext) & ~((align) - 1)) + (((p_seg->AddrNext) & ((align) - 1)) == 0 ? 0 : (align)));
    do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);

    total_size = (p_seg->AddrEnd  - p_seg->AddrBase) + 1u;
    used_size  =  p_seg->AddrNext - p_seg->AddrBase;

    if (next_addr_align > p_seg->AddrEnd){
        next_addr_align = 0u;
        rem_size        = 0u;
    } else {
        rem_size        = total_size - (next_addr_align - p_seg->AddrBase);
    }

    if (p_seg_info != 0) {
        p_seg_info->TotalSize     = total_size;
        p_seg_info->UsedSize      = used_size;
        p_seg_info->AddrBase      = p_seg->AddrBase;
        p_seg_info->AddrNextAlloc = next_addr_align;
    }

   *p_err = LIB_MEM_ERR_NONE;

    return (rem_size);
}




































 

void  *Mem_SegAlloc (const  CPU_CHAR    *p_name,
                            MEM_SEG     *p_seg,
                            CPU_SIZE_T   size,
                            LIB_ERR     *p_err)
{
    void  *p_blk;


    if (p_seg == 0) {                                     

        p_seg = &Mem_SegHeap;




    }

    p_blk = Mem_SegAllocInternal(p_name,
                                 p_seg,
                                 size,
                                 sizeof(CPU_ALIGN),
                                 1u,
                                 0,
                                 p_err);

    return (p_blk);
}






































 

void  *Mem_SegAllocExt (const  CPU_CHAR    *p_name,
                               MEM_SEG     *p_seg,
                               CPU_SIZE_T   size,
                               CPU_SIZE_T   align,
                               CPU_SIZE_T  *p_bytes_reqd,
                               LIB_ERR     *p_err)
{
    void  *p_blk;


    if (p_seg == 0) {                                     

        p_seg = &Mem_SegHeap;




    }

    p_blk = Mem_SegAllocInternal(p_name,
                                 p_seg,
                                 size,
                                 align,
                                 1u,
                                 p_bytes_reqd,
                                 p_err);

    return (p_blk);
}







































 

void  *Mem_SegAllocHW (const  CPU_CHAR    *p_name,
                              MEM_SEG     *p_seg,
                              CPU_SIZE_T   size,
                              CPU_SIZE_T   align,
                              CPU_SIZE_T  *p_bytes_reqd,
                              LIB_ERR     *p_err)
{
    void  *p_blk;


    if (p_seg == 0) {                                     

        p_seg = &Mem_SegHeap;




    }

    p_blk = Mem_SegAllocInternal(p_name,
                                 p_seg,
                                 size,
                                 align,
                                 p_seg->PaddingAlign,
                                 p_bytes_reqd,
                                 p_err);

    return (p_blk);
}





































































 


void  Mem_PoolCreate (MEM_POOL          *p_pool,
                      void              *p_mem_base,
                      CPU_SIZE_T         mem_size,
                      MEM_POOL_BLK_QTY   blk_nbr,
                      CPU_SIZE_T         blk_size,
                      CPU_SIZE_T         blk_align,
                      CPU_SIZE_T        *p_bytes_reqd,
                      LIB_ERR           *p_err)
{
    MEM_SEG           *p_seg;
    void              *p_pool_mem;
    CPU_SIZE_T         pool_size;
    CPU_SIZE_T         tbl_size;
    CPU_SIZE_T         blk_size_align;
    CPU_ADDR           pool_addr_end;
    MEM_POOL_BLK_QTY   blk_ix;
    CPU_INT08U        *p_blk;
    CPU_SR cpu_sr = (CPU_SR)0;


#line 1400 "ucLib\\lib_mem.c"

    Mem_PoolClr(p_pool, p_err);                                  
    if (*p_err != LIB_MEM_ERR_NONE) {
         return;
    }

                                                                 
    if (p_mem_base == 0) {                                
        p_seg = &Mem_SegHeap;
    } else {                                                     
        do { do { cpu_sr = CPU_SR_Save(1u << (8u - 4u));} while (0); } while (0);
        p_seg = Mem_SegOverlapChkCritical((CPU_ADDR)p_mem_base,
                                                    mem_size,
                                                    p_err);
        switch (*p_err) {
            case LIB_MEM_ERR_INVALID_SEG_EXISTS:                 
                 break;

            case LIB_MEM_ERR_NONE:                               
                 p_seg = (MEM_SEG *)Mem_SegAllocExtCritical(&Mem_SegHeap,
                                                             sizeof(MEM_SEG),
                                                             sizeof(CPU_ALIGN),
                                                             1u,
                                                             p_bytes_reqd,
                                                             p_err);
                 if (*p_err != LIB_MEM_ERR_NONE) {
                     do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);
                     return;
                 }

#line 1440 "ucLib\\lib_mem.c"

                 Mem_SegCreateCritical(          0,
                                                 p_seg,
                                       (CPU_ADDR)p_mem_base,
                                                 1u,
                                                 mem_size);
                 break;


            case LIB_MEM_ERR_INVALID_SEG_OVERLAP:
            default:
                 do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);
                 return;                                         
        }

        do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);
    }

                                                                 
                                                                 
    blk_size_align =  (((blk_size) & ~((blk_align) - 1)) + (((blk_size) & ((blk_align) - 1)) == 0 ? 0 : (blk_align)));
    pool_size      =  blk_size_align * blk_nbr;                  
    tbl_size       =  blk_nbr * sizeof(void *);                  

                                                                 
    if ((blk_size_align >  (4294967295u / blk_nbr       )) ||
        (blk_nbr        >  (4294967295u / sizeof(void *)))) {
       *p_err = LIB_MEM_ERR_ADDR_OVF;
        return;
    }

                                                                 
    p_pool_mem = (void *)Mem_SegAllocInternal("Unnamed static pool",
                                               p_seg,
                                               pool_size,
                                               blk_align,
                                               1u,
                                               p_bytes_reqd,
                                               p_err);
    if (*p_err != LIB_MEM_ERR_NONE) {
        return;
    }

                                                                 
    p_pool->BlkFreeTbl = (void **)Mem_SegAllocInternal("Unnamed static pool free blk tbl",
                                                       &Mem_SegHeap,
                                                        tbl_size,
                                                        sizeof(CPU_ALIGN),
                                                        1u,
                                                        p_bytes_reqd,
                                                        p_err);
    if (*p_err != LIB_MEM_ERR_NONE) {
        return;
    }

                                                                 
    p_blk = (CPU_INT08U *)p_pool_mem;
    for (blk_ix = 0; blk_ix < blk_nbr; blk_ix++) {
        p_pool->BlkFreeTbl[blk_ix]  = p_blk;
        p_blk                      += blk_size_align;
    }


                                                                 
    pool_addr_end         = (CPU_ADDR)p_pool_mem + (pool_size - 1u);
    p_pool->PoolAddrStart =  p_pool_mem;
    p_pool->PoolAddrEnd   = (void *)pool_addr_end;
    p_pool->BlkNbr        =  blk_nbr;
    p_pool->BlkSize       =  blk_size_align;
    p_pool->BlkFreeTblIx  =  blk_nbr;
}
































 


void  Mem_PoolClr (MEM_POOL  *p_pool,
                   LIB_ERR   *p_err)
{
#line 1560 "ucLib\\lib_mem.c"

    p_pool->PoolAddrStart = 0;
    p_pool->PoolAddrEnd   = 0;
    p_pool->BlkSize       = 0u;
    p_pool->BlkNbr        = 0u;
    p_pool->BlkFreeTbl    = 0;
    p_pool->BlkFreeTblIx  = 0u;

   *p_err = LIB_MEM_ERR_NONE;
}





























 


void  *Mem_PoolBlkGet (MEM_POOL    *p_pool,
                       CPU_SIZE_T   size,
                       LIB_ERR     *p_err)
{
    CPU_INT08U  *p_blk;
    CPU_SR cpu_sr = (CPU_SR)0;


#line 1630 "ucLib\\lib_mem.c"
    (void)size;                                                  



                                                                 
    p_blk = 0;
    do { do { cpu_sr = CPU_SR_Save(1u << (8u - 4u));} while (0); } while (0);
    if (p_pool->BlkFreeTblIx > 0u) {
        p_pool->BlkFreeTblIx                     -=  1u;
        p_blk                                     = (CPU_INT08U *)p_pool->BlkFreeTbl[p_pool->BlkFreeTblIx];
        p_pool->BlkFreeTbl[p_pool->BlkFreeTblIx]  =  0;
    }
    do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);

    if (p_blk == 0) {
       *p_err = LIB_MEM_ERR_POOL_EMPTY;
    } else {
       *p_err = LIB_MEM_ERR_NONE;
    }

    return (p_blk);
}






























 


void  Mem_PoolBlkFree (MEM_POOL  *p_pool,
                       void      *p_blk,
                       LIB_ERR   *p_err)
{




    CPU_SR cpu_sr = (CPU_SR)0;


#line 1726 "ucLib\\lib_mem.c"
    do { do { cpu_sr = CPU_SR_Save(1u << (8u - 4u));} while (0); } while (0);

                                                                 
    if (p_pool->BlkFreeTblIx >= p_pool->BlkNbr) {
        do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);
       *p_err = LIB_MEM_ERR_POOL_FULL;
        return;
    }

    p_pool->BlkFreeTbl[p_pool->BlkFreeTblIx]  = p_blk;
    p_pool->BlkFreeTblIx                     += 1u;
    do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);

   *p_err = LIB_MEM_ERR_NONE;
}

























 


MEM_POOL_BLK_QTY  Mem_PoolBlkGetNbrAvail (MEM_POOL  *p_pool,
                                          LIB_ERR   *p_err)
{
    CPU_SIZE_T  nbr_avail;
    CPU_SR cpu_sr = (CPU_SR)0;


#line 1787 "ucLib\\lib_mem.c"

    do { do { cpu_sr = CPU_SR_Save(1u << (8u - 4u));} while (0); } while (0);
    nbr_avail = p_pool->BlkFreeTblIx;
    do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);

   *p_err = LIB_MEM_ERR_NONE;

    return (nbr_avail);
}















































 

void  Mem_DynPoolCreate (const  CPU_CHAR      *p_name,
                                MEM_DYN_POOL  *p_pool,
                                MEM_SEG       *p_seg,
                                CPU_SIZE_T     blk_size,
                                CPU_SIZE_T     blk_align,
                                CPU_SIZE_T     blk_qty_init,
                                CPU_SIZE_T     blk_qty_max,
                                LIB_ERR       *p_err)
{
    if (p_seg == 0) {                                     

        p_seg = &Mem_SegHeap;




    }

    Mem_DynPoolCreateInternal(p_name,
                              p_pool,
                              p_seg,
                              blk_size,
                              blk_align,
                              1u,
                              blk_qty_init,
                              blk_qty_max,
                              p_err);
}











































 

void  Mem_DynPoolCreateHW (const  CPU_CHAR      *p_name,
                                  MEM_DYN_POOL  *p_pool,
                                  MEM_SEG       *p_seg,
                                  CPU_SIZE_T     blk_size,
                                  CPU_SIZE_T     blk_align,
                                  CPU_SIZE_T     blk_qty_init,
                                  CPU_SIZE_T     blk_qty_max,
                                  LIB_ERR       *p_err)
{
    if (p_seg == 0) {                                     

        p_seg = &Mem_SegHeap;




    }

    Mem_DynPoolCreateInternal(p_name,
                              p_pool,
                              p_seg,
                              blk_size,
                              blk_align,
                              p_seg->PaddingAlign,
                              blk_qty_init,
                              blk_qty_max,
                              p_err);
}






























 

void  *Mem_DynPoolBlkGet (MEM_DYN_POOL  *p_pool,
                          LIB_ERR       *p_err)
{
           void      *p_blk;
    const  CPU_CHAR  *p_pool_name;
    CPU_SR cpu_sr = (CPU_SR)0;


#line 1996 "ucLib\\lib_mem.c"

                                                                 
    if (p_pool->BlkQtyMax != 0u) {
        do { do { cpu_sr = CPU_SR_Save(1u << (8u - 4u));} while (0); } while (0);
        if (p_pool->BlkAllocCnt >= p_pool->BlkQtyMax) {
            do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);

           *p_err = LIB_MEM_ERR_POOL_EMPTY;
            return (0);
        }

        p_pool->BlkAllocCnt++;
        do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);
    }

                                                                 
    do { do { cpu_sr = CPU_SR_Save(1u << (8u - 4u));} while (0); } while (0);
    if (p_pool->BlkFreePtr != 0) {
        p_blk              = p_pool->BlkFreePtr;
        p_pool->BlkFreePtr = *((void **)p_blk);
        do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);

       *p_err = LIB_MEM_ERR_NONE;

        return (p_blk);
    }
    do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);

                                                                 



    p_pool_name = 0;

    p_blk = Mem_SegAllocInternal(p_pool_name,
                                 p_pool->PoolSegPtr,
                                 p_pool->BlkSize,
                                 p_pool->BlkAlign,
                                 p_pool->BlkPaddingAlign,
                                 0,
                                 p_err);
    if (*p_err != LIB_MEM_ERR_NONE) {
        if (p_pool->BlkQtyMax != 0u) {
            p_pool->BlkAllocCnt--;
        }
        return (0);
    }

    return (p_blk);
}
























 

void  Mem_DynPoolBlkFree (MEM_DYN_POOL  *p_pool,
                          void          *p_blk,
                          LIB_ERR       *p_err)
{
    CPU_SR cpu_sr = (CPU_SR)0;


#line 2094 "ucLib\\lib_mem.c"

    if (p_pool->BlkQtyMax != 0u) {        
        do { do { cpu_sr = CPU_SR_Save(1u << (8u - 4u));} while (0); } while (0);
        if (p_pool->BlkAllocCnt == 0u) {
            do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);

           *p_err = LIB_MEM_ERR_POOL_FULL;
            return;
        }

        p_pool->BlkAllocCnt--;
        do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);
    }

    do { do { cpu_sr = CPU_SR_Save(1u << (8u - 4u));} while (0); } while (0);
   *((void **)p_blk)   = p_pool->BlkFreePtr;
    p_pool->BlkFreePtr = p_blk;
    do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);

   *p_err = LIB_MEM_ERR_NONE;
}

























 

CPU_SIZE_T  Mem_DynPoolBlkNbrAvailGet (MEM_DYN_POOL  *p_pool,
                                       LIB_ERR       *p_err)
{
    CPU_SIZE_T  blk_nbr_avail;
    CPU_SR cpu_sr = (CPU_SR)0;


#line 2159 "ucLib\\lib_mem.c"

    if (p_pool->BlkQtyMax != 0u) {
        do { do { cpu_sr = CPU_SR_Save(1u << (8u - 4u));} while (0); } while (0);
        blk_nbr_avail = p_pool->BlkQtyMax - p_pool->BlkAllocCnt;
        do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);

       *p_err = LIB_MEM_ERR_NONE;
    } else {
        blk_nbr_avail = 0u;
       *p_err         = LIB_MEM_ERR_POOL_UNLIMITED;
    }

    return (blk_nbr_avail);
}




























 

#line 2294 "ucLib\\lib_mem.c"








 































 

static  void  Mem_SegCreateCritical(const  CPU_CHAR    *p_name,
                                           MEM_SEG     *p_seg,
                                           CPU_ADDR     seg_base_addr,
                                           CPU_SIZE_T   padding_align,
                                           CPU_SIZE_T   size)
{
    p_seg->AddrBase         =  seg_base_addr;
    p_seg->AddrEnd          = (seg_base_addr + (size - 1u));
    p_seg->AddrNext         =  seg_base_addr;
    p_seg->NextPtr          =  Mem_SegHeadPtr;
    p_seg->PaddingAlign     =  padding_align;





    (void)p_name;


    Mem_SegHeadPtr = p_seg;
}


























 


static  MEM_SEG  *Mem_SegOverlapChkCritical (CPU_ADDR     seg_base_addr,
                                             CPU_SIZE_T   size,
                                             LIB_ERR     *p_err)
{
    MEM_SEG   *p_seg_chk;
    CPU_ADDR   seg_new_end;
    CPU_ADDR   seg_chk_start;
    CPU_ADDR   seg_chk_end;


    seg_new_end = seg_base_addr + (size - 1u);
    p_seg_chk   = Mem_SegHeadPtr;

    while (p_seg_chk != 0) {
        seg_chk_start = (CPU_ADDR)p_seg_chk->AddrBase;
        seg_chk_end   = (CPU_ADDR)p_seg_chk->AddrEnd;

        if ((seg_base_addr == seg_chk_start) && (seg_new_end == seg_chk_end)) {
           *p_err = LIB_MEM_ERR_INVALID_SEG_EXISTS;
            return (p_seg_chk);
        } else if (((seg_base_addr >= seg_chk_start) && (seg_base_addr <= seg_chk_end)) ||
                   ((seg_base_addr <= seg_chk_start) && (seg_new_end   >= seg_chk_start))) {
           *p_err = LIB_MEM_ERR_INVALID_SEG_OVERLAP;
            return (p_seg_chk);
        } else {
                                                                 
        }

        p_seg_chk = p_seg_chk->NextPtr;
    }

   *p_err = LIB_MEM_ERR_NONE;

    return (0);
}
















































 

static  void  *Mem_SegAllocInternal (const  CPU_CHAR    *p_name,
                                            MEM_SEG     *p_seg,
                                            CPU_SIZE_T   size,
                                            CPU_SIZE_T   align,
                                            CPU_SIZE_T   padding_align,
                                            CPU_SIZE_T  *p_bytes_reqd,
                                            LIB_ERR     *p_err)
{
    void  *p_blk;
    CPU_SR cpu_sr = (CPU_SR)0;


#line 2498 "ucLib\\lib_mem.c"

    do { do { cpu_sr = CPU_SR_Save(1u << (8u - 4u));} while (0); } while (0);
    p_blk = Mem_SegAllocExtCritical(p_seg,
                                    size,
                                    align,
                                    padding_align,
                                    p_bytes_reqd,
                                    p_err);
    if (*p_err != LIB_MEM_ERR_NONE) {
        do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);
        return (0);
    }

#line 2521 "ucLib\\lib_mem.c"
    (void)p_name;

    do { do { CPU_SR_Restore(cpu_sr); } while (0); } while (0);

    return (p_blk);
}



































 

static  void  *Mem_SegAllocExtCritical (MEM_SEG     *p_seg,
                                        CPU_SIZE_T   size,
                                        CPU_SIZE_T   align,
                                        CPU_SIZE_T   padding_align,
                                        CPU_SIZE_T  *p_bytes_reqd,
                                        LIB_ERR     *p_err)
{
    CPU_ADDR    blk_addr;
    CPU_ADDR    addr_next;
    CPU_SIZE_T  size_rem_seg;
    CPU_SIZE_T  size_tot_blk;
    CPU_SIZE_T  blk_align = (((align) > (padding_align)) ? (align) : (padding_align));


    blk_addr     = (((p_seg->AddrNext) & ~((blk_align) - 1)) + (((p_seg->AddrNext) & ((blk_align) - 1)) == 0 ? 0 : (blk_align)));

    addr_next    = (((blk_addr + size) & ~((padding_align) - 1)) + (((blk_addr + size) & ((padding_align) - 1)) == 0 ? 0 : (padding_align)));

    size_rem_seg = (p_seg->AddrEnd - p_seg->AddrNext) + 1u;
    size_tot_blk =  addr_next      - p_seg->AddrNext;            
    if (size_rem_seg < size_tot_blk) {                           
        if (p_bytes_reqd != 0) {                          
           *p_bytes_reqd = size_tot_blk - size_rem_seg;
        }

       *p_err = LIB_MEM_ERR_SEG_OVF;
        return (0);
    }

    p_seg->AddrNext = addr_next;

   *p_err = LIB_MEM_ERR_NONE;

    return ((void *)blk_addr);
}





























 

#line 2669 "ucLib\\lib_mem.c"

















































 

static  void  Mem_DynPoolCreateInternal (const  CPU_CHAR      *p_name,
                                                MEM_DYN_POOL  *p_pool,
                                                MEM_SEG       *p_seg,
                                                CPU_SIZE_T     blk_size,
                                                CPU_SIZE_T     blk_align,
                                                CPU_SIZE_T     blk_padding_align,
                                                CPU_SIZE_T     blk_qty_init,
                                                CPU_SIZE_T     blk_qty_max,
                                                LIB_ERR       *p_err)
{
    CPU_INT08U  *p_blks          = 0;
    CPU_SIZE_T   seg_size;
    CPU_SIZE_T   blk_size_align;
    CPU_SIZE_T   blk_align_worst = (((blk_align) > (blk_padding_align)) ? (blk_align) : (blk_padding_align));


#line 2762 "ucLib\\lib_mem.c"

                                                                 
    if (blk_size < sizeof(void *)) {                             
                                                                 
        blk_size_align = (((sizeof(void *)) & ~((blk_align_worst) - 1)) + (((sizeof(void *)) & ((blk_align_worst) - 1)) == 0 ? 0 : (blk_align_worst)));
    } else {
        blk_size_align = (((blk_size) & ~((blk_align_worst) - 1)) + (((blk_size) & ((blk_align_worst) - 1)) == 0 ? 0 : (blk_align_worst)));
    }

    if (blk_qty_init != 0u) {                                    
        CPU_SIZE_T  i;

        seg_size = blk_size_align * blk_qty_init;                
                                                                 
        if (blk_size_align > (4294967295u / blk_qty_init)) {
           *p_err = LIB_MEM_ERR_ADDR_OVF;
            return;
        }

        p_blks = (CPU_INT08U *)Mem_SegAllocInternal(p_name,
                                                    p_seg,
                                                    seg_size,
                                                    (((blk_align) > (sizeof(void *))) ? (blk_align) : (sizeof(void *))),
                                                    1u,
                                                    0,
                                                    p_err);
        if (*p_err != LIB_MEM_ERR_NONE) {
            return;
        }

                                                                 
                                                                 
        p_pool->BlkFreePtr = (void *)p_blks;
        for (i = 0u; i < blk_qty_init - 1u; i++) {
           *((void **)p_blks)  = p_blks + blk_size_align;
            p_blks            += blk_size_align;
        }
       *((void **)p_blks) = 0;
    } else {
        p_pool->BlkFreePtr = 0;
    }


    p_pool->PoolSegPtr      = ((p_seg != 0) ? p_seg : &Mem_SegHeap);



    p_pool->BlkSize         =   blk_size;
    p_pool->BlkAlign        =   blk_align_worst;
    p_pool->BlkPaddingAlign =   blk_padding_align;
    p_pool->BlkQtyMax       =   blk_qty_max;
    p_pool->BlkAllocCnt     =   0u;





   *p_err = LIB_MEM_ERR_NONE;
}






















 

