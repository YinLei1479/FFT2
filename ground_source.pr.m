MIL_3_Tfile_Hdr_ 145A 140A modeler 9 66C2E7F7 66E3DAB2 6 ray-laptop 28918 0 0 none none 0 0 none C23C498F 15EF 0 0 0 0 0 0 1bcc 1                                                                                                                                                                                                                                                                                                                                                                                               ЋЭg      @   D   H        Ы  Я  г  з  у  ч  ы             	   begsim intrpt         
   џџџџ   
   doc file            	nd_module      endsim intrpt         
   џџџџ   
   failure intrpts            disabled      intrpt interval         дВI­%У}џџџџ      priority              џџџџ      recovery intrpts            disabled      subqueue                     count    џџџ   
   џџџџ   
      list   	џџџ   
          
      super priority             џџџџ             Objid	\process_id;       Objid	\node_id;       double	\start_time;       double	\interval;       Boolean	\send_DATA;       int	\node_address;       int	\traffic_load;       Boolean	\infinity;       char	\node_type[10];       int	\final_dest;       int	\pk_num;       int	\pk_dest;          //File   	FILE *in;   char temp_file_name[300];      #define SEND_STRM 0       B#define END	        		    	(op_intrpt_type() == OPC_INTRPT_ENDSIM)       .//Self-interrupt code and transition condition   #define SEND_DATA_S_CODE		100   h#define SEND_DATA_S				((op_intrpt_type() == OPC_INTRPT_SELF) && (op_intrpt_code() == SEND_DATA_S_CODE))   0//Remote-interrupt code and transition condition   #define FRAME_BEGIN				2000   e#define SEND_DATA_R				((op_intrpt_type() == OPC_INTRPT_REMOTE) && (op_intrpt_code() == FRAME_BEGIN))       //function prototype   'static void create_and_send_DATA(void);      static void   create_and_send_DATA(void)   {   //var   	Packet * pk_DATA;   //in   	FIN(create_and_send_DATA());   //body   5	pk_DATA = op_pk_create_fmt("Appointment_request_G");   $	op_pk_nfd_set(pk_DATA,"TYPE",0x15);   $	op_pk_nfd_set(pk_DATA,"SEND",0xFE);   *	op_pk_nfd_set(pk_DATA,"DEST_ID",pk_dest);   %	op_pk_nfd_set(pk_DATA,"Num",pk_num);   &	op_pk_nfd_set(pk_DATA,"Data_Type",0);   	   	op_pk_send(pk_DATA,SEND_STRM);   	   	FOUT;   }                                                      
   init   
       J      // Obtain related ID   process_id = op_id_self();   &node_id = op_topo_parent(process_id);       	pk_num=0;   
pk_dest=0;       >//op_intrpt_schedule_self(op_sim_time()+500,SEND_DATA_S_CODE);   J                     
   џџџџ   
          pr_state        J            
   idle   
                                   
    џџџџ   
          pr_state        J   Z          
   send DATA S   
       
      create_and_send_DATA();       	pk_num++;   if(pk_num==16) pk_num=0;   
pk_dest++;   if(pk_dest==13) pk_num=0;       <op_intrpt_schedule_self(op_sim_time()+100,SEND_DATA_S_CODE);       printf("In \"gsrc\",time:%f,\n\   1		Have created DATA and sent it to \"gmac\".\n",\   		op_sim_time());       
                     
   џџџџ   
          pr_state        J  Т          
   send DATA R   
       
       
                     
   џџџџ   
          pr_state        ў            
   end   
       
      if(send_DATA)   {   /	if(op_ima_obj_attr_exists(node_id,"Log File"))   	{	   9		op_ima_obj_attr_get(node_id,"Log File",temp_file_name);   "		in = fopen(temp_file_name,"at");   W		fprintf(in,"НкЕу %d ЙВЗЂГіЪ§ОнАќИіЪ§:%d.(in \"gsrc->end\")\r\n",node_address,pk_num);   5		fprintf(in,"ЗЂАќМфИєЮЊЃК%f seconds.\r\n",interval);   9		fprintf(in,"Simulation time: %f s.\r\n",op_sim_time());   		fprintf(in,"End.\r\n\r\n");   		fclose(in);   	}   }else if(pk_num!=0)   {       N	if(op_ima_obj_attr_exists(node_id,"Log File")&&(strcmp(node_type,"sink")==0))   	{	   9		op_ima_obj_attr_get(node_id,"Log File",temp_file_name);   "		in = fopen(temp_file_name,"at");   e		fprintf(in,"НкЕу %d ЭЈЙ§дЖГЬжаЖЯЃЌЙВЗЂГіЪ§ОнАќИіЪ§:%d.(in \"gsrc->end\")\r\n",node_address,pk_num);   7		//fprintf(in,"ЗЂАќМфИєЮЊЃК%f seconds.\r\n",interval);   9		fprintf(in,"Simulation time: %f s.\r\n",op_sim_time());   		fprintf(in,"End.\r\n\r\n");   		fclose(in);   	}   }   
                         џџџџ             pr_state                        ј        Ќ    D            
   tr_0   
       џџџџ          џџџџ          
    џџџџ   
          џџџџ                       pr_transition              P   Г     Q   t  Q   ђ          
   tr_2   
       џџџџ          џџџџ          
    џџџџ   
          џџџџ                       pr_transition                 Д     F   ѕ  G   v          
   tr_3   
       
   SEND_DATA_S   
       џџџџ          
    џџџџ   
          џџџџ                       pr_transition                i     E  %  D  Ї          
   tr_4   
       
   SEND_DATA_R   
       џџџџ          
    џџџџ   
          џџџџ                       pr_transition              T  g     S  Ћ  T  #          
   tr_5   
       џџџџ          џџџџ          
    џџџџ   
          џџџџ                       pr_transition              Ћ       [    њ            
   tr_6   
       
   END   
       џџџџ          
    џџџџ   
          џџџџ                       pr_transition                                             