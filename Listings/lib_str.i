#line 1 "ucLib\\lib_str.c"














 



































 





 

#line 1 ".\\ucLib\\lib_str.h"














 
























 








 












 

































 














































 

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








 





#line 146 ".\\ucLib\\lib_str.h"

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








 

#line 62 "ucLib\\lib_str.c"






 






 






 






 

static  const  CPU_INT32U  Str_MultOvfThTbl_Int32U[] = {
   (CPU_INT32U) 4294967295u,                 
   (CPU_INT32U)(4294967295u /  1u),          
   (CPU_INT32U)(4294967295u /  2u),          
   (CPU_INT32U)(4294967295u /  3u),          
   (CPU_INT32U)(4294967295u /  4u),          
   (CPU_INT32U)(4294967295u /  5u),          
   (CPU_INT32U)(4294967295u /  6u),          
   (CPU_INT32U)(4294967295u /  7u),          
   (CPU_INT32U)(4294967295u /  8u),          
   (CPU_INT32U)(4294967295u /  9u),          
   (CPU_INT32U)(4294967295u / 10u),          
   (CPU_INT32U)(4294967295u / 11u),          
   (CPU_INT32U)(4294967295u / 12u),          
   (CPU_INT32U)(4294967295u / 13u),          
   (CPU_INT32U)(4294967295u / 14u),          
   (CPU_INT32U)(4294967295u / 15u),          
   (CPU_INT32U)(4294967295u / 16u),          
   (CPU_INT32U)(4294967295u / 17u),          
   (CPU_INT32U)(4294967295u / 18u),          
   (CPU_INT32U)(4294967295u / 19u),          
   (CPU_INT32U)(4294967295u / 20u),          
   (CPU_INT32U)(4294967295u / 21u),          
   (CPU_INT32U)(4294967295u / 22u),          
   (CPU_INT32U)(4294967295u / 23u),          
   (CPU_INT32U)(4294967295u / 24u),          
   (CPU_INT32U)(4294967295u / 25u),          
   (CPU_INT32U)(4294967295u / 26u),          
   (CPU_INT32U)(4294967295u / 27u),          
   (CPU_INT32U)(4294967295u / 28u),          
   (CPU_INT32U)(4294967295u / 29u),          
   (CPU_INT32U)(4294967295u / 30u),          
   (CPU_INT32U)(4294967295u / 31u),          
   (CPU_INT32U)(4294967295u / 32u),          
   (CPU_INT32U)(4294967295u / 33u),          
   (CPU_INT32U)(4294967295u / 34u),          
   (CPU_INT32U)(4294967295u / 35u),          
   (CPU_INT32U)(4294967295u / 36u)           
};






 






 

static  CPU_CHAR    *Str_FmtNbr_Int32  (       CPU_INT32U     nbr,
                                               CPU_INT08U     nbr_dig,
                                               CPU_INT08U     nbr_base,
                                               CPU_BOOLEAN    nbr_neg,
                                               CPU_CHAR       lead_char,
                                               CPU_BOOLEAN    lower_case,
                                               CPU_BOOLEAN    nul,
                                               CPU_CHAR      *pstr);

static  CPU_INT32U   Str_ParseNbr_Int32(const  CPU_CHAR      *pstr,
                                               CPU_CHAR     **pstr_next,
                                               CPU_INT08U     nbr_base,
                                               CPU_BOOLEAN    nbr_signed,
                                               CPU_BOOLEAN   *pnbr_neg);






 







































 

CPU_SIZE_T  Str_Len (const  CPU_CHAR  *pstr)
{
    CPU_SIZE_T  len;


    len = Str_Len_N(pstr,
                    4294967295u);

    return (len);
}















































 

CPU_SIZE_T  Str_Len_N (const  CPU_CHAR    *pstr,
                              CPU_SIZE_T   len_max)
{
    const  CPU_CHAR    *pstr_len;
           CPU_SIZE_T   len;


    pstr_len = pstr;
    len      = 0u;
    while (( pstr_len != (const CPU_CHAR *)  0 ) &&              
           (*pstr_len != (      CPU_CHAR  )'\0') &&              
           ( len      <  (      CPU_SIZE_T)len_max)) {           
        pstr_len++;
        len++;
    }

    return (len);                                                
}




















































 

CPU_CHAR  *Str_Copy (       CPU_CHAR  *pstr_dest,
                     const  CPU_CHAR  *pstr_src)
{
    CPU_CHAR  *pstr_rtn;


    pstr_rtn = Str_Copy_N(pstr_dest,
                          pstr_src,
                          4294967295u);

    return (pstr_rtn);
}












































































 

CPU_CHAR  *Str_Copy_N (       CPU_CHAR    *pstr_dest,
                       const  CPU_CHAR    *pstr_src,
                              CPU_SIZE_T   len_max)
{
           CPU_CHAR    *pstr_copy_dest;
    const  CPU_CHAR    *pstr_copy_src;
           CPU_SIZE_T   len_copy;

                                                                 
    if (pstr_dest == (CPU_CHAR *)0) {
        return ((CPU_CHAR *)0);
    }
    if (pstr_src  == (const CPU_CHAR *)0) {
        return ((CPU_CHAR *)0);
    }


    pstr_copy_dest = pstr_dest;
    pstr_copy_src  = pstr_src;
    len_copy       = 0u;

    while (( pstr_copy_dest != (      CPU_CHAR *)  0 ) &&        
           ( pstr_copy_src  != (const CPU_CHAR *)  0 ) &&
           (*pstr_copy_src  != (      CPU_CHAR  )'\0') &&        
           ( len_copy       <  (      CPU_SIZE_T)len_max)) {     
       *pstr_copy_dest = *pstr_copy_src;
        pstr_copy_dest++;
        pstr_copy_src++;
        len_copy++;
    }

                                                                 
    if ((pstr_copy_dest == (      CPU_CHAR *)0) ||
        (pstr_copy_src  == (const CPU_CHAR *)0)) {
         return ((CPU_CHAR *)0);
    }

    if (len_copy < len_max) {                                    
       *pstr_copy_dest = (CPU_CHAR)'\0';                         
    }


    return (pstr_dest);                                          
}
























































 

CPU_CHAR  *Str_Cat (       CPU_CHAR  *pstr_dest,
                    const  CPU_CHAR  *pstr_cat)
{
    CPU_CHAR  *pstr_rtn;


    pstr_rtn = Str_Cat_N(pstr_dest,
                         pstr_cat,
                         4294967295u);

    return (pstr_rtn);
}




































































 

CPU_CHAR  *Str_Cat_N (       CPU_CHAR    *pstr_dest,
                      const  CPU_CHAR    *pstr_cat,
                             CPU_SIZE_T   len_max)
{
           CPU_CHAR    *pstr_cat_dest;
    const  CPU_CHAR    *pstr_cat_src;
           CPU_SIZE_T   len_cat;

                                                                 
    if (pstr_dest == (CPU_CHAR *)0) {
        return ((CPU_CHAR *)0);
    }
    if (pstr_cat  == (const CPU_CHAR *)0) {
        return ((CPU_CHAR *)0);
    }

    if (len_max < 1) {                                           
        return ((CPU_CHAR *)pstr_dest);
    }


    pstr_cat_dest = pstr_dest;
    while (( pstr_cat_dest != (CPU_CHAR *)  0 ) &&               
           (*pstr_cat_dest != (CPU_CHAR  )'\0')) {               
        pstr_cat_dest++;
    }

    if (pstr_cat_dest == (CPU_CHAR *)0) {                        
        return ((CPU_CHAR *)0);
    }

    pstr_cat_src = pstr_cat;
    len_cat      = 0u;

    while (( pstr_cat_dest != (      CPU_CHAR *)  0 ) &&         
           ( pstr_cat_src  != (const CPU_CHAR *)  0 ) &&
           (*pstr_cat_src  != (      CPU_CHAR  )'\0') &&         
           ( len_cat       <  (      CPU_SIZE_T)len_max)) {      
       *pstr_cat_dest = *pstr_cat_src;
        pstr_cat_dest++;
        pstr_cat_src++;
        len_cat++;
    }

                                                                 
    if ((pstr_cat_dest == (      CPU_CHAR *)0) ||
        (pstr_cat_src  == (const CPU_CHAR *)0)) {
         return ((CPU_CHAR *)0);
    }

   *pstr_cat_dest = (CPU_CHAR)'\0';                              


    return (pstr_dest);                                          
}











































































 

CPU_INT16S  Str_Cmp (const  CPU_CHAR  *p1_str,
                     const  CPU_CHAR  *p2_str)
{
    CPU_INT16S  cmp_val;


    cmp_val = Str_Cmp_N(p1_str,
                        p2_str,
                        4294967295u);

    return (cmp_val);
}























































































 

CPU_INT16S  Str_Cmp_N (const  CPU_CHAR    *p1_str,
                       const  CPU_CHAR    *p2_str,
                              CPU_SIZE_T   len_max)
{
    const  CPU_CHAR    *p1_str_cmp;
    const  CPU_CHAR    *p2_str_cmp;
    const  CPU_CHAR    *p1_str_cmp_next;
    const  CPU_CHAR    *p2_str_cmp_next;
           CPU_INT16S   cmp_val;
           CPU_SIZE_T   cmp_len;


    if (len_max < 1) {                                           
        return (0);
    }

    if (p1_str == (const CPU_CHAR *)0) {
        if (p2_str == (const CPU_CHAR *)0) {
            return (0);                                          
        }
        cmp_val = (CPU_INT16S)((CPU_INT16S)0 - (CPU_INT16S)(*p2_str));
        return (cmp_val);                                        
    }
    if (p2_str == (const CPU_CHAR *)0) {
        cmp_val = (CPU_INT16S)(*p1_str);
        return (cmp_val);                                        
    }


    p1_str_cmp      = p1_str;
    p2_str_cmp      = p2_str;
    p1_str_cmp_next = p1_str_cmp;
    p2_str_cmp_next = p2_str_cmp;
    p1_str_cmp_next++;
    p2_str_cmp_next++;
    cmp_len         = 0u;

    while ((*p1_str_cmp      == *p2_str_cmp)            &&       
           (*p1_str_cmp      != (      CPU_CHAR  )'\0') &&       
           ( p1_str_cmp_next != (const CPU_CHAR *)  0 ) &&       
           ( p2_str_cmp_next != (const CPU_CHAR *)  0 ) &&
           ( cmp_len         <  (      CPU_SIZE_T)len_max)) {    
        p1_str_cmp++;
        p2_str_cmp++;
        p1_str_cmp_next++;
        p2_str_cmp_next++;
        cmp_len++;
    }


    if (cmp_len == len_max) {                                    
        return (0);                                              
    }

    if (*p1_str_cmp != *p2_str_cmp) {                            
                                                                 
         cmp_val = (CPU_INT16S)((CPU_INT16S)(*p1_str_cmp) - (CPU_INT16S)(*p2_str_cmp));

    } else if (*p1_str_cmp  == (CPU_CHAR)'\0') {                 
         cmp_val = (CPU_INT16S)0;                                

    } else {
        if (p1_str_cmp_next == (const CPU_CHAR *)0) {
            if (p2_str_cmp_next == (const CPU_CHAR *)0) {        
                cmp_val = (CPU_INT16S)0;                         
            } else {                                             
                                                                 
                cmp_val = (CPU_INT16S)((CPU_INT16S)0 - (CPU_INT16S)(*p2_str_cmp_next));
            }
        } else {                                                 
            cmp_val = (CPU_INT16S)(*p1_str_cmp_next);            
        }
    }


    return (cmp_val);
}





















































































 

CPU_INT16S  Str_CmpIgnoreCase (const  CPU_CHAR  *p1_str,
                               const  CPU_CHAR  *p2_str)
{
    CPU_INT16S  cmp_val;


    cmp_val = Str_CmpIgnoreCase_N(p1_str,
                                  p2_str,
                                  4294967295u);

    return (cmp_val);
}

































































































 

CPU_INT16S  Str_CmpIgnoreCase_N (const  CPU_CHAR    *p1_str,
                                 const  CPU_CHAR    *p2_str,
                                        CPU_SIZE_T   len_max)
{
    const  CPU_CHAR    *p1_str_cmp;
    const  CPU_CHAR    *p2_str_cmp;
    const  CPU_CHAR    *p1_str_cmp_next;
    const  CPU_CHAR    *p2_str_cmp_next;
           CPU_CHAR     char_1;
           CPU_CHAR     char_2;
           CPU_INT16S   cmp_val;
           CPU_SIZE_T   cmp_len;


    if (len_max < 1) {                                           
        return (0);
    }

    if (p1_str == (const CPU_CHAR *)0) {
        if (p2_str == (const CPU_CHAR *)0) {
            return (0);                                          
        }
        char_2  =  ASCII_ToLower(*p2_str);
        cmp_val = (CPU_INT16S)((CPU_INT16S)0 - (CPU_INT16S)char_2);
        return (cmp_val);                                        
    }
    if (p2_str == (const CPU_CHAR *)0) {
        char_1  =  ASCII_ToLower(*p1_str);
        cmp_val = (CPU_INT16S)char_1;
        return (cmp_val);                                        
    }


    p1_str_cmp      = p1_str;
    p2_str_cmp      = p2_str;
    p1_str_cmp_next = p1_str_cmp;
    p2_str_cmp_next = p2_str_cmp;
    p1_str_cmp_next++;
    p2_str_cmp_next++;
    char_1          = ASCII_ToLower(*p1_str_cmp);
    char_2          = ASCII_ToLower(*p2_str_cmp);
    cmp_len         = 0u;

    while (( char_1          ==  char_2)                &&       
           (*p1_str_cmp      != (      CPU_CHAR  )'\0') &&       
           ( p1_str_cmp_next != (const CPU_CHAR *)  0 ) &&       
           ( p2_str_cmp_next != (const CPU_CHAR *)  0 ) &&
           ( cmp_len         <  (      CPU_SIZE_T)len_max)) {    
        p1_str_cmp++;
        p2_str_cmp++;
        p1_str_cmp_next++;
        p2_str_cmp_next++;
        cmp_len++;
        char_1 = ASCII_ToLower(*p1_str_cmp);
        char_2 = ASCII_ToLower(*p2_str_cmp);
    }


    if (cmp_len == len_max) {                                    
        return (0);                                              
    }

    if (char_1 != char_2) {                                      
                                                                 
         cmp_val = (CPU_INT16S)((CPU_INT16S)char_1 - (CPU_INT16S)char_2);

    } else if (char_1 == (CPU_CHAR)'\0') {                       
         cmp_val = (CPU_INT16S)0;                                

    } else {
        if (p1_str_cmp_next == (const CPU_CHAR *)0) {
            if (p2_str_cmp_next == (const CPU_CHAR *)0) {        
                cmp_val = (CPU_INT16S)0;                         
            } else {                                             
                char_2  =  ASCII_ToLower(*p2_str_cmp_next);
                                                                 
                cmp_val = (CPU_INT16S)((CPU_INT16S)0 - (CPU_INT16S)char_2);
            }
        } else {                                                 
            char_1  =  ASCII_ToLower(*p1_str_cmp_next);
            cmp_val = (CPU_INT16S)char_1;                        
        }
    }


    return (cmp_val);
}




















































 

CPU_CHAR  *Str_Char (const  CPU_CHAR  *pstr,
                            CPU_CHAR   srch_char)
{
    CPU_CHAR  *pstr_rtn;


    pstr_rtn = Str_Char_N(pstr,
                          4294967295u,
                          srch_char);

    return (pstr_rtn);
}


































































 

CPU_CHAR  *Str_Char_N (const  CPU_CHAR    *pstr,
                              CPU_SIZE_T   len_max,
                              CPU_CHAR     srch_char)
{
    const  CPU_CHAR    *pstr_char;
           CPU_SIZE_T   len_srch;


    if (pstr == (const CPU_CHAR *)0) {                           
        return ((CPU_CHAR *)0);
    }

    if (len_max < 1) {                                           
        return ((CPU_CHAR *)0);
    }


    pstr_char = pstr;
    len_srch  = 0u;

    while (( pstr_char != (const CPU_CHAR *)  0 )      &&        
           (*pstr_char != (      CPU_CHAR  )'\0')      &&        
           (*pstr_char != (      CPU_CHAR  )srch_char) &&        
           ( len_srch  <  (      CPU_SIZE_T)len_max)) {          
        pstr_char++;
        len_srch++;
    }

    if (pstr_char == (const CPU_CHAR *)0) {                      
        return ((CPU_CHAR *)0);
    }

    if (len_srch >= len_max) {                                   
        return ((CPU_CHAR *)0);                                  
    }

    if (*pstr_char != srch_char) {                               
         return ((CPU_CHAR *)0);
    }


    return ((CPU_CHAR *)pstr_char);                              
}



















































 

CPU_CHAR  *Str_Char_Last (const  CPU_CHAR  *pstr,
                                 CPU_CHAR   srch_char)
{
    CPU_CHAR  *pstr_rtn;


    pstr_rtn = Str_Char_Last_N(pstr,
                               4294967295u,
                               srch_char);

    return (pstr_rtn);
}




































































 

CPU_CHAR  *Str_Char_Last_N (const  CPU_CHAR    *pstr,
                                   CPU_SIZE_T   len_max,
                                   CPU_CHAR     srch_char)
{
    const  CPU_CHAR    *pstr_char;
           CPU_SIZE_T   str_len_max;
           CPU_SIZE_T   str_len;


    if (pstr == (const CPU_CHAR *)0) {                           
        return ((CPU_CHAR *)0);
    }

    if (len_max < 1) {                                           
        return ((CPU_CHAR *)0);
    }


    pstr_char    = pstr;
     str_len_max = len_max - sizeof("");                         
     str_len     = Str_Len_N(pstr_char, str_len_max);
    pstr_char   += str_len;

    if (pstr_char == (const CPU_CHAR *)0) {                      
        return ((CPU_CHAR *)0);
    }

    while (( pstr_char != pstr) &&                               
           (*pstr_char != srch_char)) {                          
        pstr_char--;
    }


    if (*pstr_char != srch_char) {                               
         return ((CPU_CHAR *)0);
    }


    return ((CPU_CHAR *)pstr_char);                              
}





































 

CPU_CHAR  *Str_Char_Replace (CPU_CHAR  *pstr,
                             CPU_CHAR   char_srch,
                             CPU_CHAR   char_replace)
{
    CPU_CHAR  *pstr_rtn;


    pstr_rtn = Str_Char_Replace_N(pstr,
                                  char_srch,
                                  char_replace,
                                  4294967295u);

    return (pstr_rtn);
}














































 

CPU_CHAR  *Str_Char_Replace_N (CPU_CHAR    *pstr,
                               CPU_CHAR     char_srch,
                               CPU_CHAR     char_replace,
                               CPU_SIZE_T   len_max)
{
    CPU_CHAR    *pstr_char;
    CPU_SIZE_T   len;


    if (pstr == (const CPU_CHAR *)0) {                           
        return ((CPU_CHAR *)0);
    }

    if (len_max < 1) {                                           
        return ((CPU_CHAR *)0);
    }

    pstr_char = pstr;
    len       = len_max;

    while (( pstr_char != (const CPU_CHAR *)0) &&                
           (*pstr_char !=  0x00   ) &&                
           ( len        >                   0)) {                

        if (*pstr_char == char_srch) {
            *pstr_char  = char_replace;                          
        }

        pstr_char++;
        len--;
    }

    return (pstr);
}




























































 

CPU_CHAR  *Str_Str (const  CPU_CHAR  *pstr,
                    const  CPU_CHAR  *pstr_srch)
{
    CPU_CHAR  *pstr_rtn;


    pstr_rtn = Str_Str_N(pstr,
                         pstr_srch,
                         4294967295u);

    return (pstr_rtn);
}






































































 

CPU_CHAR  *Str_Str_N (const  CPU_CHAR    *pstr,
                      const  CPU_CHAR    *pstr_srch,
                             CPU_SIZE_T   len_max)
{
           CPU_SIZE_T    str_len;
           CPU_SIZE_T    str_len_srch;
           CPU_SIZE_T    len_max_srch;
           CPU_SIZE_T    srch_len;
           CPU_SIZE_T    srch_ix;
           CPU_BOOLEAN   srch_done;
           CPU_INT16S    srch_cmp;
    const  CPU_CHAR     *pstr_str;
    const  CPU_CHAR     *pstr_srch_ix;

                                                                 
    if (pstr == (const CPU_CHAR *)0) {
        return ((CPU_CHAR *)0);
    }
    if (pstr_srch == (const CPU_CHAR *)0) {
        return ((CPU_CHAR *)0);
    }

    if (len_max < 1) {                                           
        return ((CPU_CHAR *)0);
    }

                                                                 
    len_max_srch = (len_max <       4294967295u)
                 ? (len_max + 1u) : 4294967295u;

    str_len      = Str_Len_N(pstr,      len_max);
    str_len_srch = Str_Len_N(pstr_srch, len_max_srch);
    if (str_len_srch < 1) {                                      
        return ((CPU_CHAR *)pstr);
    }
    if (str_len_srch > str_len) {                                
        return ((CPU_CHAR *)0);
    }

                                                                 
    pstr_str = pstr      + str_len;
    if (pstr_str == (const CPU_CHAR *)0) {
        return ((CPU_CHAR *)0);
    }
    pstr_str = pstr_srch + str_len_srch;
    if (pstr_str == (const CPU_CHAR *)0) {
        return ((CPU_CHAR *)0);
    }

    srch_len  = str_len - str_len_srch;                          
    srch_ix   = 0u;

    do {
        pstr_srch_ix = (const CPU_CHAR *)(pstr + srch_ix);
        srch_cmp     =  Str_Cmp_N(pstr_srch_ix, pstr_srch, str_len_srch);
        srch_done    = (srch_cmp == 0) ? 1u : 0u;
        srch_ix++;
    } while ((srch_done == 0u) && (srch_ix <= srch_len));


    if (srch_cmp != 0) {                                         
        return ((CPU_CHAR *)0);
    }

    return ((CPU_CHAR *)pstr_srch_ix);                           
}




























































































































 

CPU_CHAR  *Str_FmtNbr_Int32U (CPU_INT32U    nbr,
                              CPU_INT08U    nbr_dig,
                              CPU_INT08U    nbr_base,
                              CPU_CHAR      lead_char,
                              CPU_BOOLEAN   lower_case,
                              CPU_BOOLEAN   nul,
                              CPU_CHAR     *pstr)
{
    CPU_CHAR  *pstr_fmt;


    pstr_fmt = Str_FmtNbr_Int32(nbr,                             
                                nbr_dig,
                                nbr_base,
                                0u,
                                lead_char,
                                lower_case,
                                nul,
                                pstr);

    return (pstr_fmt);
}
































































































































































































 

CPU_CHAR  *Str_FmtNbr_Int32S (CPU_INT32S    nbr,
                              CPU_INT08U    nbr_dig,
                              CPU_INT08U    nbr_base,
                              CPU_CHAR      lead_char,
                              CPU_BOOLEAN   lower_case,
                              CPU_BOOLEAN   nul,
                              CPU_CHAR     *pstr)
{
    CPU_CHAR     *pstr_fmt;
    CPU_INT32S    nbr_fmt;
    CPU_BOOLEAN   nbr_neg;


    if (nbr < 0) {                                               
        nbr_fmt = -nbr;                                          
        nbr_neg =  1u;
    } else {
        nbr_fmt =  nbr;
        nbr_neg =  0u;
    }

    pstr_fmt = Str_FmtNbr_Int32((CPU_INT32U)nbr_fmt,             
                                            nbr_dig,
                                            nbr_base,
                                            nbr_neg,
                                            lead_char,
                                            lower_case,
                                            nul,
                                            pstr);

    return (pstr_fmt);
}























































































































































































































































































 

#line 2770 "ucLib\\lib_str.c"


































































































































































































 

CPU_INT32U  Str_ParseNbr_Int32U (const  CPU_CHAR     *pstr,
                                        CPU_CHAR    **pstr_next,
                                        CPU_INT08U    nbr_base)
{
    CPU_INT32U  nbr;


    nbr = Str_ParseNbr_Int32(               pstr,                
                                            pstr_next,
                                            nbr_base,
                                            0u,              
                             (CPU_BOOLEAN *)0);

    return (nbr);
}







































































































































































































 

CPU_INT32S  Str_ParseNbr_Int32S (const  CPU_CHAR     *pstr,
                                        CPU_CHAR    **pstr_next,
                                        CPU_INT08U    nbr_base)
{
    CPU_INT32S   nbr;
    CPU_INT32U   nbr_abs;
    CPU_BOOLEAN  nbr_neg;


    nbr_abs = Str_ParseNbr_Int32(pstr,                           
                                 pstr_next,
                                 nbr_base,
                                 1u,                        
                                &nbr_neg);

    if (nbr_neg == 0u) {                                     
        nbr = (nbr_abs > (CPU_INT32U) 2147483647)          ?  (CPU_INT32S)2147483647
                                                                    :  (CPU_INT32S)nbr_abs;
    } else {
        nbr = (nbr_abs > (CPU_INT32U)-(-2147483647)) ?  (CPU_INT32S)((-2147483647) - 1)
                                                                    : -(CPU_INT32S)nbr_abs;
    }

    return (nbr);
}








 



























































































































































































































 

static  CPU_CHAR  *Str_FmtNbr_Int32 (CPU_INT32U    nbr,
                                     CPU_INT08U    nbr_dig,
                                     CPU_INT08U    nbr_base,
                                     CPU_BOOLEAN   nbr_neg,
                                     CPU_CHAR      lead_char,
                                     CPU_BOOLEAN   lower_case,
                                     CPU_BOOLEAN   nul,
                                     CPU_CHAR     *pstr)
{
    CPU_CHAR     *pstr_fmt;
    CPU_DATA      i;
    CPU_INT32U    nbr_fmt            = 0;
    CPU_INT32U    nbr_log;
    CPU_INT08U    nbr_dig_max;
    CPU_INT08U    nbr_dig_min;
    CPU_INT08U    nbr_dig_fmtd       = 0;
    CPU_INT08U    nbr_neg_sign;
    CPU_INT08U    nbr_lead_char;
    CPU_INT08U    dig_val;
    CPU_INT08U    lead_char_delta_0;
    CPU_INT08U    lead_char_delta_a;
    CPU_BOOLEAN   lead_char_dig;
    CPU_BOOLEAN   lead_char_0;
    CPU_BOOLEAN   fmt_valid          = 1u;
    CPU_BOOLEAN   print_char;
    CPU_BOOLEAN   nbr_neg_fmtd       = 0u;


                                                                 
    if (pstr == (CPU_CHAR *)0) {                                 
        return ((CPU_CHAR *)0);
    }

    if (nbr_dig < 1) {                                           
        fmt_valid = 0u;                                      
    }
                                                                 
    if ((nbr_base <  2u) ||
        (nbr_base > 36u)) {
        fmt_valid = 0u;                                      
    }

    if (lead_char != (CPU_CHAR)'\0') {
        print_char =  ASCII_IsPrint(lead_char);
        if (print_char != 1u) {                             
            fmt_valid = 0u;                                  

        } else if (lead_char != '0') {                           
            lead_char_delta_0 = (CPU_INT08U)(lead_char - '0');
            if (lower_case != 1u) {
                lead_char_delta_a = (CPU_INT08U)(lead_char - 'A');
            } else {
                lead_char_delta_a = (CPU_INT08U)(lead_char - 'a');
            }

            lead_char_dig = (((nbr_base <= 10u) &&  (lead_char_delta_0 <  nbr_base))      ||
                             ((nbr_base >  10u) && ((lead_char_delta_0 <             10u) ||
                                                    (lead_char_delta_a < (nbr_base - 10u))))) ? 1u : 0u;

            if (lead_char_dig == 1u) {                      
                fmt_valid = 0u;                              
            }
        } else {
                                                                 
        }
    }


                                                                 
    pstr_fmt    = pstr;
    lead_char_0 = 0u;

    if (fmt_valid == 1u) {
        nbr_fmt     = nbr;
        nbr_log     = nbr;
        nbr_dig_max = 1u;
        while (nbr_log >= nbr_base) {                            
            nbr_dig_max++;                                       
            nbr_log /= nbr_base;
        }

        nbr_neg_sign = (nbr_neg == 1u) ? 1u : 0u;
        if (nbr_dig >= (nbr_dig_max + nbr_neg_sign)) {           
            nbr_neg_fmtd = 0u;
            nbr_dig_min  = (((nbr_dig_max) < (nbr_dig)) ? (nbr_dig_max) : (nbr_dig));
                                                                 
            if (lead_char != (CPU_CHAR)'\0') {
                nbr_dig_fmtd  = nbr_dig;
                nbr_lead_char = nbr_dig     -
                               (nbr_dig_min + nbr_neg_sign);
            } else {
                nbr_dig_fmtd  = nbr_dig_min + nbr_neg_sign;
                nbr_lead_char = 0u;
            }

            if (nbr_lead_char > 0) {                             
                lead_char_0 = (lead_char == '0')                 
                            ?  1u : 0u;
            }

        } else {                                                 
            fmt_valid = 0u;                                  
        }
    }

    if (fmt_valid == 0u) {
        nbr_dig_fmtd = nbr_dig;
    }


                                                                 
    pstr_fmt += nbr_dig_fmtd;                                    

    if (nul != 0u) {                                         
       *pstr_fmt = (CPU_CHAR)'\0';
    }
    pstr_fmt--;


    for (i = 0u; i < nbr_dig_fmtd; i++) {                        
        if (fmt_valid == 1u) {
            if ((nbr_fmt > 0) ||                                 
                (i == 0u)) {                                     
                                                                 
                dig_val = (CPU_INT08U)(nbr_fmt % nbr_base);
                if (dig_val < 10u) {
                   *pstr_fmt-- = (CPU_CHAR)(dig_val + '0');
                } else {
                    if (lower_case !=  1u) {
                       *pstr_fmt--  = (CPU_CHAR)((dig_val - 10u) + 'A');
                    } else {
                       *pstr_fmt--  = (CPU_CHAR)((dig_val - 10u) + 'a');
                    }
                }

                nbr_fmt /= nbr_base;                             

            } else if ((nbr_neg      == 1u)  &&             
                     (((lead_char_0  == 0u )  &&             
                       (nbr_neg_fmtd == 0u )) ||             
                      ((lead_char_0  != 0u )  &&             
                       (i == (nbr_dig_fmtd - 1u))))) {           

               *pstr_fmt--   = '-';                              
                nbr_neg_fmtd = 1u;

            } else if (lead_char != (CPU_CHAR)'\0') {            
               *pstr_fmt-- = lead_char;                          
            } else {
                                                                 
            }

        } else {                                                 
           *pstr_fmt-- = '?';
        }
    }


    if (fmt_valid == 0u) {                                 
        return ((CPU_CHAR *)0);
    }


    return (pstr);                                               
}


































































































































































































































 

static  CPU_INT32U  Str_ParseNbr_Int32 (const  CPU_CHAR      *pstr,
                                               CPU_CHAR     **pstr_next,
                                               CPU_INT08U     nbr_base,
                                               CPU_BOOLEAN    nbr_signed,
                                               CPU_BOOLEAN   *pnbr_neg)
{
    const  CPU_CHAR     *pstr_parse;
    const  CPU_CHAR     *pstr_parse_nbr;
           CPU_CHAR     *pstr_parse_unused;
           CPU_CHAR      parse_char;
           CPU_INT08U    parse_dig;
           CPU_INT32U    nbr;
           CPU_BOOLEAN   nbr_neg_unused;
           CPU_BOOLEAN   nbr_dig;
           CPU_BOOLEAN   nbr_alpha;
           CPU_BOOLEAN   nbr_hex;
           CPU_BOOLEAN   nbr_hex_lower;
           CPU_BOOLEAN   whitespace;
           CPU_BOOLEAN   neg;
           CPU_BOOLEAN   ovf;
           CPU_BOOLEAN   done;

                                                                 
    if (pstr_next == (CPU_CHAR **) 0) {                          
        pstr_next  = (CPU_CHAR **)&pstr_parse_unused;            
       (void)pstr_parse_unused;                                  
    }
   *pstr_next = (CPU_CHAR *)pstr;                                

    if (pnbr_neg == (CPU_BOOLEAN *) 0) {                         
        pnbr_neg  = (CPU_BOOLEAN *)&nbr_neg_unused;              
       (void)nbr_neg_unused;                                     
    }
   *pnbr_neg = 0u;                                           


    if (pstr == (CPU_CHAR *)0) {                                 
        return (0u);
    }
                                                                 
    if ((nbr_base == 1u) ||
        (nbr_base > 36u)) {
        return (0u);
    }


                                                                 
    pstr_parse = pstr;                                           

    whitespace = ASCII_IsSpace(*pstr_parse);
    while (whitespace == 1u) {                              
        pstr_parse++;
        whitespace = ASCII_IsSpace(*pstr_parse);
    }

    switch (*pstr_parse) {
        case '+':                                                
             pstr_parse++;
             neg = 0u;
             break;


        case '-':                                                
             if (nbr_signed == 1u) {
                 pstr_parse++;
             }
             neg = 1u;
             break;


        default:
             neg = 0u;
             break;
    }


                                                                 
    pstr_parse_nbr = pstr_parse;                                 

    switch (nbr_base) {
        case  0u:                                                
             if (*pstr_parse == '0') {                           
                  pstr_parse++;                                  
                  switch (*pstr_parse) {
                      case 'x':                                  
                      case 'X':
                           nbr_base   = 16u;                     
                           parse_char = (CPU_CHAR)(*(pstr_parse + 1));
                           nbr_hex    =  ASCII_IsDigHex(parse_char);
                           if (nbr_hex == 1u) {             
                               pstr_parse++;                     
                           }
                           break;


                      default:                                   
                           nbr_base =  8u;                       
                           break;
                  }

             } else {                                            
                 nbr_base = 10u;                                 
             }
             break;


        case  8u:                                                
             if (*pstr_parse == '0') {                           
                  pstr_parse++;                                  
             }
             break;


        case 16u:                                                
             if (*pstr_parse == '0') {                           
                  pstr_parse++;                                  
                  switch (*pstr_parse) {
                      case 'x':
                      case 'X':
                           parse_char = (CPU_CHAR)(*(pstr_parse + 1));
                           nbr_hex    =  ASCII_IsDigHex(parse_char);
                           if (nbr_hex == 1u) {             
                               pstr_parse++;                     
                           }
                           break;


                      default:
                           break;
                  }
             }
             break;


        default:                                                 
             break;
    }


                                                                 
    nbr  = 0u;
    ovf  = 0u;
    done = 0u;

    while (done == 0u) {                                     
        parse_char = (CPU_CHAR)*pstr_parse;
        nbr_alpha  =  ASCII_IsAlphaNum(parse_char);
        if (nbr_alpha == 1u) {                              
                                                                 
            nbr_dig = ASCII_IsDig(parse_char);
            if (nbr_dig == 1u) {
                parse_dig = (CPU_INT08U)(parse_char - '0');
            } else {
                nbr_hex_lower = ASCII_IsLower(parse_char);
                if (nbr_hex_lower == 1u) {
                    parse_dig = ((CPU_INT08U)(parse_char - 'a') + 10u);
                } else {
                    parse_dig = ((CPU_INT08U)(parse_char - 'A') + 10u);
                }
            }

            if (parse_dig < nbr_base) {                          
                if (ovf == 0u) {                             
                    if (nbr <= Str_MultOvfThTbl_Int32U[nbr_base]) {
                                                                 
                        nbr *= nbr_base;
                        nbr += parse_dig;
                        if (nbr < parse_dig) {
                            ovf = 1u;
                        }
                    } else {
                        ovf = 1u;
                    }
                }
                pstr_parse++;

            } else {                                             
                done = 1u;
            }

        } else {                                                 
            done = 1u;
        }
    }

    if (ovf == 1u) {                                        
        nbr  = 4294967295u;                              
    }


    if (pstr_parse !=             pstr_parse_nbr) {              
       *pstr_next   = (CPU_CHAR *)pstr_parse;                    
    } else {
       *pstr_next   = (CPU_CHAR *)pstr;                          
    }

   *pnbr_neg = neg;                                              


    return (nbr);
}
