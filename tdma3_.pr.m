MIL_3_Tfile_Hdr_ 145A 140A modeler 9 66A366DA 66EA9565 2E ray-laptop 28918 0 0 none none 0 0 none 4388CB3F 4AF7 0 0 0 0 0 0 1bcc 1                                                                                                                                                                                                                                                                                                                                                                                              ��g�      @   D   �  T  X  o  >y  >}  C@  H�  H�  H�  H�  c          Slot Length   �������      seconds       ?�      ����              ����              ����           �Z             	   begsim intrpt         
   ����   
   doc file            	nd_module      endsim intrpt             ����      failure intrpts            disabled      intrpt interval         ԲI�%��}����      priority              ����      recovery intrpts            disabled      subqueue         
            count    ���   
   ����   
      list   	���   
                bit capacity   ���   
T�I�%��}����   
      pk capacity   ���   
T�I�%��}����   
         bit capacity   ���   
T�I�%��}����   
      pk capacity   ���   
T�I�%��}����   
   
   
   super priority             ����          7   int	\my_offset;       double	\slot_length;       double	\tx_data_rate;       Objid	\my_node_id;       Objid	\my_id;       int	\my_address;       
int	\type;       /* number of neighbor */   int	\nei_count;       /* two hop neighbor address */   int	\my_two_nei[24];       /* 0 or 1 for is my slot ? */   int	\is_my_slot;       /* interactive node address */   int	\interactive_id;       /* initiai wait self intrpt */   Evhandle	\evh1;       /* all slot number */   int	\num_slots;       int	\my_node_state;       int	\my_clock_level;       7/* record in a frame                                 */   7/* node_id + nei_offset + CL + Location + node_state */   int	\a_frame_record[8][7];       /* neighbor in last frame */   int	\a_frame_record_last[8][7];       int	\nei_num_last;       int	\node_num;       double	\Longitude;       double	\Latitude;       double	\Height;       int	\time[24];          Packet*	pkptr;       !Objid 	tx_id, comp_id, tx_ch_id;        int	used_slots;   int	current_offset;   //int	next_offset;           double	current_time;   double	time_left_in_slot;   double	pk_len;   double	pk_time;       //double	my_next_slot_time;       int		current_intrpt_type;       int i,j;   (   #include <math.h>       /* Constant Definitions */   #define RX_IN_STRM		(1)   #define SRC_IN_STRM		(0)   #define TX_OUT_STRM		(1)   #define SINK_OUT_STRM	(0)       7#define EPSILON  		(1e-10)  /* rounding error factor */   #define TDMA_COMPLETE	(-10)   #define FRAME_BEGIN		(2000)   #define INTACT_BEGIN	(4000)               "/* Transition Condition Macros */    U#define NET_BUILD		(op_intrpt_type() == OPC_INTRPT_SELF) && (op_intrpt_code () == 11)   U#define NET_IN			(op_intrpt_type() == OPC_INTRPT_SELF) && (op_intrpt_code () == 1111)   [#define RX_STRM			(op_intrpt_type() == OPC_INTRPT_STRM) && (op_intrpt_strm() == RX_IN_STRM)   _#define FROM_RX			(current_intrpt_type == OPC_INTRPT_STRM) && (op_intrpt_strm () == RX_IN_STRM)   b#define FROM_SRC 		(current_intrpt_type == OPC_INTRPT_STRM) && (op_intrpt_strm () == SRC_IN_STRM)    5#define TRANSMITTING	(op_stat_local_read (0) == 1.0)    T#define SLOT 			(current_intrpt_type == OPC_INTRPT_SELF) && (op_intrpt_code () == 0)   Y#define MY_SLOT 		(current_intrpt_type == OPC_INTRPT_SELF) && (op_intrpt_code () == 3000)   U#define NO_DATA 		((op_subq_empty (0)) && (op_subq_empty (1)) && (op_subq_empty (2)))       ,#define	SELF_INTRPT_SCHLD	(intrpt_flag == 1)       /* Global Variables */   int		tdma_pk_sent;   int		tdma_pk_rcvd;   int		tdma_bits_sent;   int		tdma_bits_rcvd;   int		tdma_setup;   int		tdma_id;           static void QWZ_create(void);   #static void QWZ_rcv(Packet* pkptr);       q   'static void QWZ_create(void)//QWZ_CREAT   	{   	Packet* pkptr;   		int min;   	int intact_next;   	int i;   	   	FIN(QWZ_create())       	pkptr=op_pk_create_fmt("QWZ");       %	op_pk_nfd_set (pkptr, "TYPE", 0x00);   4	op_pk_nfd_set (pkptr, "node_state", my_node_state);   -	op_pk_nfd_set (pkptr, "Nei_num", nei_count);   *	op_pk_nfd_set (pkptr, "Slot", my_offset);   =	op_pk_nfd_set (pkptr, "Nei_address_0",a_frame_record[0][0]);   =	op_pk_nfd_set (pkptr, "Nei_address_1",a_frame_record[1][0]);   =	op_pk_nfd_set (pkptr, "Nei_address_2",a_frame_record[2][0]);   =	op_pk_nfd_set (pkptr, "Nei_address_3",a_frame_record[3][0]);   =	op_pk_nfd_set (pkptr, "Nei_address_4",a_frame_record[4][0]);   =	op_pk_nfd_set (pkptr, "Nei_address_5",a_frame_record[5][0]);   =	op_pk_nfd_set (pkptr, "Nei_address_6",a_frame_record[6][0]);   =	op_pk_nfd_set (pkptr, "Nei_address_7",a_frame_record[7][0]);   .	op_pk_nfd_set (pkptr, "Longitude",Longitude);   ,	op_pk_nfd_set (pkptr, "Latitude",Latitude);   (	op_pk_nfd_set (pkptr, "Height",Height);   	   
	min=0xFF;   	for(i=0;i<8;i++)   		{   <		if(a_frame_record[i][0]!=0xFF && a_frame_record[i][2]<min)   			{   			min=a_frame_record[i][2];   $			intact_next=a_frame_record[i][0];   			}   		}   -	if(my_clock_level>min) my_clock_level=min+1;   	   6	op_pk_nfd_set (pkptr, "Clock_level", my_clock_level);   	   -	op_subq_pk_insert (1, pkptr, OPC_QPOS_TAIL);   	   	FOUT   	}               +static void QWZ_rcv(Packet* pkptr)//QWZ_RCV   	{   	int nei_id;   	int nei_slot;   	int nei_CL;   	int nei_state;   	int two_nei_num;   	int two_nei_id[8];   	int nei_longitude;   	int nei_latitude;   	int nei_height;   	int i;   	   	FIN(QWZ_rcv(Packet* pkptr))   	   (	op_pk_nfd_get (pkptr, "SEND", &nei_id);   *	op_pk_nfd_get (pkptr, "Slot", &nei_slot);   1	op_pk_nfd_get (pkptr, "node_state", &nei_state);   /	op_pk_nfd_get (pkptr, "Clock_level", &nei_CL);   4	op_pk_nfd_get (pkptr, "Longitude", &nei_longitude);   2	op_pk_nfd_get (pkptr, "Latitude", &nei_latitude);   .	op_pk_nfd_get (pkptr, "Height", &nei_height);   	   	   		//record   %	a_frame_record[nei_count][0]=nei_id;   '	a_frame_record[nei_count][1]=nei_slot;   %	a_frame_record[nei_count][2]=nei_CL;   ,	a_frame_record[nei_count][3]=nei_longitude;   +	a_frame_record[nei_count][4]=nei_latitude;   )	a_frame_record[nei_count][5]=nei_height;   (	a_frame_record[nei_count][6]=nei_state;   	nei_count++;   				   	//neighbor			   0	op_pk_nfd_get (pkptr, "Nei_num", &two_nei_num);   8	op_pk_nfd_get (pkptr, "Nei_address_0", &two_nei_id[0]);   8	op_pk_nfd_get (pkptr, "Nei_address_1", &two_nei_id[1]);   8	op_pk_nfd_get (pkptr, "Nei_address_2", &two_nei_id[2]);   8	op_pk_nfd_get (pkptr, "Nei_address_3", &two_nei_id[3]);   8	op_pk_nfd_get (pkptr, "Nei_address_4", &two_nei_id[4]);   8	op_pk_nfd_get (pkptr, "Nei_address_5", &two_nei_id[5]);   8	op_pk_nfd_get (pkptr, "Nei_address_6", &two_nei_id[6]);   8	op_pk_nfd_get (pkptr, "Nei_address_7", &two_nei_id[7]);   	for(i=0;i<two_nei_num;i++)   		my_two_nei[two_nei_id[i]]=2;   	   	//�ڵ�״̬����   	for(i=0;i<two_nei_num;i++)   		{   3		if(two_nei_id[i]==my_address && my_node_state==1)   			my_node_state=2;   		}   	//begin node   	if(my_node_state==1)   		{   H		my_offset=((nei_slot+(my_address-nei_id))%node_num+node_num)%node_num;   		time[my_offset]=1;   		}   	   	op_pk_destroy(pkptr);   	   	FOUT   	}                                               �   �          
   init   
       
   *   /*important setting*/   Bop_ima_sim_attr_get (OPC_IMA_DOUBLE, "Slot Length", &slot_length);   interactive_id=4;   node_num=13;       /*initial begin*/   my_id = op_id_self();   $my_node_id = op_topo_parent (my_id);   num_slots = node_num;   6op_ima_obj_attr_get(my_node_id,"Address",&my_address);   +if(my_address==interactive_id) my_offset=0;   Gif(my_address==interactive_id) my_clock_level=0; else my_clock_level=7;   Eif(my_address==interactive_id) my_node_state=7; else my_node_state=1;   nei_count=0;   nei_num_last=0;   is_my_slot=0;   for(i=0;i<8;i++)   	{   	for(j=0;j<7;j++)   		{   		a_frame_record[i][j]=0xFF;   !		a_frame_record_last[i][j]=0xFF;   		}   	}   "for(i=0;i<24;i++) my_two_nei[i]=0;   for(i=0;i<24;i++) time[i]=0;   )if(my_address==interactive_id) time[0]=1;   Longitude=0;   Latitude=0;   	Height=0;       1/* Determine the data rate for the transmitter */   Itx_id =  op_topo_assoc (my_id, OPC_TOPO_ASSOC_OUT, OPC_OBJTYPE_RATX, 0);    5comp_id = op_topo_child (tx_id, OPC_OBJTYPE_COMP, 0);   :tx_ch_id = op_topo_child (comp_id, OPC_OBJTYPE_RATXCH, 0);   <op_ima_obj_attr_get (tx_ch_id, "data rate", &tx_data_rate);            D/* Schedule interupt to complete initialization in the exit execs */   Eprintf("%%%%%%%%%%% %d tdma init is over%%%%%%%%%%%%%\n",my_address);   1op_intrpt_schedule_self (op_sim_time(), 0);//slot       
       
       
       
   ����   
          pr_state      	  �   �          
   idle   
       
       
       
      (current_intrpt_type = op_intrpt_type ();   
       
    ����   
          pr_state        �   Z          
   fr_rx   
       J      int next_hop;        pkptr =  op_pk_get (RX_IN_STRM);   %op_pk_nfd_get (pkptr, "TYPE", &type);       if(type==0x00)//QWZ   	{   	QWZ_rcv(pkptr);   9	printf("%d now has %d neighbor\n",my_address,nei_count);   	}       +else if(type==0x01)//�򽻻��ڵ㷢�͵��ϱ�֡   	{   .	op_pk_nfd_get (pkptr, "Next_Hop", &next_hop);   	if(next_hop!=my_address)   		{   		op_pk_destroy(pkptr);   		}   	else   		{   "		printf("zhgongzhuan shoudao\n");   "		op_pk_send(pkptr,SINK_OUT_STRM);   		}   	}       J       
       
       
   ����   
          pr_state        :   �          
   fr_src   
       
      !pkptr =  op_pk_get (SRC_IN_STRM);   %op_pk_nfd_get (pkptr, "TYPE", &type);       &if(type==0x01)//�򽻻��ڵ㷢�͵��ϱ�֡   	{   -	op_subq_pk_insert (1, pkptr, OPC_QPOS_TAIL);   	}       
       
       
       
   ����   
          pr_state        �  �          
   tx   
       
   K   int min;   int intact_next;   Ici* mac_ici;   double x,y,z;   current_time = op_sim_time();   Bused_slots = (int) floor ((current_time / slot_length) + EPSILON);   (current_offset = used_slots % num_slots;   //ԤԼ��һ��ʱ϶   Dop_intrpt_schedule_self ((double) (used_slots +1) * slot_length, 0);   //location get   Eop_ima_obj_pos_get(my_node_id,&Latitude,&Longitude,&Height,&x,&y,&z);   c//printf("location get:%d-- %lf %lf %lf %lf %lf %lf\n",my_address,Latitude,Longitude,Height,x,y,z);   //����ʱ϶�����ɲ�����QWZ   if(time[current_offset]==1)   	{   	is_my_slot=1;   6	if(my_node_state==2 && nei_count==0) my_node_state=1;   	//����   #	if(my_node_state!=3) QWZ_create();   	//���ò�����Ϣ   	for(i=0;i<8;i++)   		{   		for(j=0;j<5;j++)   			{   2			a_frame_record_last[i][j]=a_frame_record[i][j];   			a_frame_record[i][j]=0xFF;   			}   		}   	nei_num_last=nei_count;   	nei_count=0;   	for(i=0;i<24;i++)   '		if(my_two_nei[i]!=0) my_two_nei[i]--;   	}   else   	{   	is_my_slot=0;   	}   /if(used_slots%200==0 && used_slots>0)//�ϱ�ʱ��   	{   '	pkptr=op_pk_create_fmt("link_report");   "	op_pk_nfd_set(pkptr,"TYPE",0x01);   *	op_pk_nfd_set(pkptr,"Source",my_address);   C	op_pk_nfd_set (pkptr, "Nei_address_0", a_frame_record_last[0][0]);   C	op_pk_nfd_set (pkptr, "Nei_address_1", a_frame_record_last[1][0]);   C	op_pk_nfd_set (pkptr, "Nei_address_2", a_frame_record_last[2][0]);   C	op_pk_nfd_set (pkptr, "Nei_address_3", a_frame_record_last[3][0]);   C	op_pk_nfd_set (pkptr, "Nei_address_4", a_frame_record_last[4][0]);   C	op_pk_nfd_set (pkptr, "Nei_address_5", a_frame_record_last[5][0]);   C	op_pk_nfd_set (pkptr, "Nei_address_6", a_frame_record_last[6][0]);   C	op_pk_nfd_set (pkptr, "Nei_address_7", a_frame_record_last[7][0]);   ,	op_pk_nfd_set(pkptr,"Longitude",Longitude);   *	op_pk_nfd_set(pkptr,"Latitude",Latitude);   &	op_pk_nfd_set(pkptr,"Height",Height);   	//ѡ����һ��   
	min=0xFF;   	for(i=0;i<8;i++)   		{   F		if(a_frame_record_last[i][0]!=0xFF && a_frame_record_last[i][2]<min)   			{   !			min=a_frame_record_last[i][2];   )			intact_next=a_frame_record_last[i][0];   			}   		}   ;	printf("abc:%d-%d--CL___%d\n",my_address,intact_next,min);   1	mac_ici = (Ici*)op_ici_create("mac_to_net_ici");   ?	op_ici_attr_set_int32(mac_ici, "mac_to_net_ici", intact_next);   	   	//������NET   	for(i=0;i<8;i++)   %		if(a_frame_record_last[i][0]==0xFF)   				break;   $	op_pk_nfd_set (pkptr, "Nei_num",i);   	op_ici_install(mac_ici);   !	op_pk_send(pkptr,SINK_OUT_STRM);   	}   
       
       
       
   ����   
          pr_state         �  �          
   tx_queue   
       
   :   int FLAG=0;   %/* Determine if currently my slot. */   current_time = op_sim_time();   Bused_slots = (int) floor ((current_time / slot_length) + EPSILON);   (current_offset = used_slots % num_slots;   Btime_left_in_slot = ((used_slots + 1)*slot_length) - current_time;       /* dequeue the packet */   if(op_subq_empty(0)==0)   	{   ,	pkptr=op_subq_pk_access (0, OPC_QPOS_HEAD);   1	pk_len = (double) op_pk_total_size_get (pkptr);    *	pk_time = (double) pk_len / tx_data_rate;    	if(pk_time < time_left_in_slot)   		{   ,		pkptr=op_subq_pk_remove(0, OPC_QPOS_HEAD);   			FLAG=1;   		}   	}   'else if(op_subq_empty(1)==0 && FLAG==0)   	{   ,	pkptr=op_subq_pk_access (1, OPC_QPOS_HEAD);   1	pk_len = (double) op_pk_total_size_get (pkptr);    *	pk_time = (double) pk_len / tx_data_rate;    	if(pk_time < time_left_in_slot)   		{   ,		pkptr=op_subq_pk_remove(1, OPC_QPOS_HEAD);   			FLAG=1;   		}   	}   'else if(op_subq_empty(2)==0 && FLAG==0)   	{   ,	pkptr=op_subq_pk_access (2, OPC_QPOS_HEAD);   1	pk_len = (double) op_pk_total_size_get (pkptr);    *	pk_time = (double) pk_len / tx_data_rate;    	if(pk_time < time_left_in_slot)   		{   ,		pkptr=op_subq_pk_remove(2, OPC_QPOS_HEAD);   			FLAG=1;   		}   	}       if (FLAG==1)   	{   	/* full pk */   (	op_pk_nfd_set(pkptr,"SEND",my_address);   "	op_pk_nfd_set(pkptr,"FL",pk_len);       	/* send it! */   	op_pk_print(pkptr);   !	op_pk_send (pkptr, TX_OUT_STRM);       	} /* End if */       else   	{   	is_my_slot=0;   	}   
                     
   ����   
          pr_state               	   	     �     k   �     �     �  l   �          
   tr_10   
       
   default   
       
����   
       
    ����   
       
   ����   
                    pr_transition         	     T   �     t   �  t   o          
   tr_13   
       
   FROM_RX   
       
����   
       
    ����   
       
   ����   
                    pr_transition            	  �   �     �   m  �   �          
   tr_14   
       
����   
       
����   
       
    ����   
       
   ����   
                    pr_transition      #   	     �   �     �   �  #   �          
   tr_15   
       
   FROM_SRC   
       
����   
       
    ����   
       
   ����   
                    pr_transition      +      	  R  !     v  n  v   �          
   tr_18   
       
   (!is_my_slot) || (NO_DATA)   
       
����   
       
    ����   
       
   ����   
                    pr_transition      /   	     �  =     �   �  �  l          
   tr_19   
       
   SLOT    
       
����   
       
    ����   
       
   ����   
                    pr_transition      =        1  s     u  �   �  �          
   tr_61   
       
   is_my_slot && !NO_DATA    
       ����          
    ����   
          ����                       pr_transition      >      	   �  9      �  t     �  v   �          
   tr_62   
       
   !is_my_slot || NO_DATA   
       ����          
    ����   
          ����                       pr_transition      P      	  �   �     +   �  �   �          
   tr_80   
       
����   
       ����          
    ����   
          ����                       pr_transition      X         K  g      �  t   �  M   �  o   �  z          
   tr_88   
       
   is_my_slot && !NO_DATA   
       ����          
    ����   
          ����                       pr_transition      [      	  -   �      �   �  o   �          
   tr_91   
       ����          ����          
    ����   
          ����                       pr_transition         ]          Load (bits)          (Number of bits broadcast by this node.          TDMA   bucket/default total/sum   linear        ԲI�%��}   Load (bits/sec)          'Number of bits per second broadcast by    this node.      TDMA   bucket/default total/sum_time   linear        ԲI�%��}   Load (packets)          $Number of packets broadcast by this    node.      TDMA   bucket/default total/sum   linear        ԲI�%��}   Load (packets/sec)          'Number of packets per second broadcast    by this node.      TDMA   bucket/default total/sum_time   linear        ԲI�%��}   Traffic Received (bits)          'Number of bits received by this node.     TDMA   bucket/default total/sum   linear        ԲI�%��}   Traffic Received (bits/sec)          &Number of bits per second received by    this node.      TDMA   bucket/default total/sum_time   linear        ԲI�%��}   Traffic Received (packets)          #Number of packets received by this    node.    TDMA   bucket/default total/sum   linear        ԲI�%��}   Traffic Received (packets/sec)          &Number of packets per second received    by this node.       TDMA   bucket/default total/sum_time   linear        ԲI�%��}      TDMA Load (bits)          &Total number of bits broadcast by all    tdma capable nodes.     TDMA   bucket/default total/sum   linear        ԲI�%��}   TDMA Load (bits/sec)           Total number of bits per second    &broadcast by all tdma capable nodes.     TDMA   bucket/default total/sum_time   linear        ԲI�%��}   TDMA Load (packets)          #Total number of packets per second    %broadcast by all tdma capable nodes.    TDMA   bucket/default total/sum_time   linear        ԲI�%��}   TDMA Load (packets/sec)          #Total number of packets per second    %broadcast by all tdma capable nodes.    TDMA   bucket/default total/sum_time   linear        ԲI�%��}   TDMA Traffic Received (bits)           Total number of bits per second    $received by all tdma capable nodes.    TDMA   bucket/default total/sum_time   linear        ԲI�%��}    TDMA Traffic Received (bits/sec)           Total number of bits per second    $received by all tdma capable nodes.    TDMA   bucket/default total/sum_time   linear        ԲI�%��}   TDMA Traffic Received (packets)          (Total number of packets received by all    tdma capable nodes.    TDMA   bucket/default total/sum   linear        ԲI�%��}   #TDMA Traffic Received (packets/sec)          #Total number of packets per second    $received by all tdma capable nodes.    TDMA   bucket/default total/sum_time   linear        ԲI�%��}                           