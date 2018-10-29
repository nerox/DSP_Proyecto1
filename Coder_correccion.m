function Coder_correccion()
  filename='Herida_32bits.wav';
  [input_music_array,Fs]=audioread(filename);

  str_metadatos=json_decoder('metadatos.json',"Se codificaran los siguientes metadatos");
  metadatos=insertarMetadatos(str_metadatos);
  str_parametros=json_decoder('parametros_usuario.json',"Se utilizaran los siguientes parametros");
  parametros_usuario=set_parametros_codificacion(str_parametros);
  disp("Inicializando la generacion de ventanas");
  ventanas= creador_de_ventanas(input_music_array,parametros_usuario(1)); 
  disp("realizando el multiplexado");
  [cantidad_de_ventanas,tamano_ventana] = size(ventanas);
  ventanas_multiplexadas=multiplexado(ventanas,metadatos,parametros_usuario,cantidad_de_ventanas);
  disp("implementando la combinacion de ventanas");
  #ventanas_combinadas=overlap_sum(ventanas_multiplexadas,parametros_usuario,cantidad_de_ventanas);
  ventanas_combinadas=combinacion_ventanas(ventanas_multiplexadas,parametros_usuario,cantidad_de_ventanas);
  output_array=generate_audio_array(ventanas_combinadas);
  audiowrite("output.wav",ventanas_combinadas,Fs);  
  disp("generando el audio de salida");
end

function jsonfile_str_output=json_decoder(filename,message_display)
  jsonfile_str_output=read_file(filename);
  disp(message_display);
  disp(jsonfile_str_output);
end

function str_file=read_file(file_name)
  fid = fopen(file_name); 
  raw = fread(fid,inf); 
  str_file = char(raw'); 
  fclose(fid); 
end

#funcion de prueba para verificar que al unir ventanas se genera el audio de entrada
function output_array=generate_audio_array(inputarray)
  [rows,columns] = size(inputarray);
  output_array=[];
  for(index=1:rows)
    output_array=[output_array,inputarray(index,:)];
  end
end

function metadatos=insertarMetadatos(str_metadatos)  
  originalword =  toascii(str_metadatos);
  #disp(originalword);
  metadatos="";
  for i=1:length(originalword)
    metadatos = strcat(metadatos,dec2bin(originalword(i),7));
    #disp(dec2bin(originalword(i),7));   
  end
  #disp(length(metadatos));
end

function metadatos_string=recibir_datos(input_data,metadatos_string_input,key)
  s=input(input_data,"s"); 
  metadatos_string=strcat(metadatos_string_input,key);  
  metadatos_string=strcat(metadatos_string_input,s);
end

function vetanas_reducidas = creador_de_ventanas(input_music_array, tamano_ventana)
  tamano_input=length(input_music_array);
  #disp(length(input_music_array));
  cantidad_de_ventanas=tamano_input/tamano_ventana;
  vetanas_reducidas_fixed=floor(cantidad_de_ventanas);
  #disp(vetanas_reducidas_fixed);
  ventana_output=[];
  ventana_actual=[];
  for index_ventana_actual=1:vetanas_reducidas_fixed;
    #ventana_actual = zeros(1,tamano_ventana);
    ventana_actual=[];
    for index_elemento_ventana_actual=1:tamano_ventana;
      ventana_actual= [ventana_actual, input_music_array((index_ventana_actual-1)*tamano_ventana+index_elemento_ventana_actual)];    
    end
    ventana_output= [ventana_output;ventana_actual];
  end
  vetanas_reducidas=ventana_output;
end 

function params=set_parametros_codificacion(string_parametros)
  Parametros_substring=strsplit(string_parametros,',');
  M=str2num(strsplit(Parametros_substring{1,1},':'){2});
  N= str2num(strsplit(Parametros_substring{1,2},':'){2});
  a0= str2num(strsplit(Parametros_substring{1,3},':'){2});
  a1= str2num(strsplit(Parametros_substring{1,4},':'){2});
  t0= str2num(strsplit(Parametros_substring{1,5},':'){2});
  t1= str2num(strsplit(Parametros_substring{1,6},':'){2});
  params=[M,N,a0,a1,t0,t1];
end

function ventanas_multiplexadas=multiplexado(ventanas,metadatos,parametros_usuario,cantidad_de_ventanas)
  tamano_respuesta_impulso=parametros_usuario(2);
  a0=parametros_usuario(3);
  a1=parametros_usuario(4);  
  t0=parametros_usuario(5);
  t1=parametros_usuario(6);  
  ventanas_multiplexadas=[];  
  index_multiplexado=1;
  index_codificador=1;
  while(index_multiplexado<cantidad_de_ventanas-3)
    respuesta_impulso=zeros(1,tamano_respuesta_impulso); 
    ventana_codificada=[]; 
    if(index_codificador<=length(metadatos))
      if(metadatos(index_codificador)=='0')
        respuesta_impulso(1)=1;
        respuesta_impulso(t0)=a0;
      else
        respuesta_impulso(1)=1;
        respuesta_impulso(t1)=a1;
      end
      #ventanas_multiplexadas=[ventanas_multiplexadas;ventana_codificada];
    else
      respuesta_impulso(1)=1;
      respuesta_impulso(t0)=a0;
      #ventanas_multiplexadas=[ventanas_multiplexadas;ventana_codificada];
    end
    ventana_codificada=conv(ventanas(index_multiplexado,:),respuesta_impulso);
    ventana_codificada1=conv(ventanas(index_multiplexado+1,:),respuesta_impulso);
    ventana_codificada2=conv(ventanas(index_multiplexado+2,:),respuesta_impulso);
    ventanas_multiplexadas=[ventanas_multiplexadas;ventana_codificada;ventana_codificada1;ventana_codificada2];
    index_multiplexado=index_multiplexado+3;
    index_codificador=index_codificador+1;
  end
end

function ventanas_combinadas=combinacion_ventanas(ventanas_multiplexadas,parametros_usuario,cantidad_de_ventanas)
  tamano_ventana=parametros_usuario(1);
  tamano_respuesta_impulso=parametros_usuario(2);
  tamano_convolucion=tamano_ventana+tamano_respuesta_impulso-1;
  primer_ventana=ventanas_multiplexadas(1,1:tamano_ventana);
  overlap=ventanas_multiplexadas(1,tamano_ventana+1:tamano_convolucion);
  zeros_aggregate=zeros(1,tamano_ventana);
  overlap=[overlap,zeros_aggregate];
  ventanas_combinadas=primer_ventana;
  for(index_multiplexado=2:cantidad_de_ventanas-3)
    #nth_ventana=overlap+ventanas_multiplexadas(index_multiplexado,:);
    nth_ventana=ventanas_multiplexadas(index_multiplexado,:);
    nth_ventana_recortada=nth_ventana(1,1:tamano_ventana);
    overlap=[nth_ventana(1,tamano_ventana+1:tamano_convolucion),zeros_aggregate];
    ventanas_combinadas=[ventanas_combinadas,nth_ventana_recortada];
  
  end  
end

function ventanas_combinadas=overlap_sum(ventanas_multiplexadas,parametros_usuario,cantidad_de_ventanas)
  tamano_ventana=parametros_usuario(1);
  tamano_respuesta_impulso=parametros_usuario(2);
  tamano_displacement=ceil(tamano_respuesta_impulso/2);
  tamano_convolucion=tamano_ventana+tamano_respuesta_impulso-1;
  ventanas_combinadas=[];
  primer_ventana=ventanas_multiplexadas(1,1:tamano_ventana);
  ventanas_combinadas=[ventanas_combinadas,primer_ventana];
  for(index=1:cantidad_de_ventanas-1)
    primer_ventana=ventanas_multiplexadas(index,tamano_respuesta_impulso/2:tamano_ventana+tamano_respuesta_impulso/2);
    #overlap_onx=ventanas_multiplexadas(index+1,1:tamano_displacement);
    #zeros_aggregatex=zeros(1,tamano_ventana-tamano_displacement); 
    #zeros_aggregatex=[zeros_aggregatex,overlap_onx];
    #primer_ventana=primer_ventana;
    #overlap_ony=ventanas_multiplexadas(index,tamano_ventana+tamano_displacement:tamano_convolucion);
    #zeros_aggregatey=zeros(1,tamano_ventana+tamano_displacement-1);
    #overlap_ony=[overlap_ony,zeros_aggregatey];
    #ventanas_multiplexadas(index,:)=overlap_ony+ventanas_multiplexadas(index,:);
    ventanas_combinadas=[ventanas_combinadas,primer_ventana];
  end
  ventanas_combinadas=[ventanas_combinadas,ventanas_multiplexadas(cantidad_de_ventanas,1:tamano_ventana)];
  #for(index_multiplexado=2:cantidad_de_ventanas)
  #  nth_ventana=overlap+ventanas_multiplexadas(index_multiplexado,:);
  #  nth_ventana_recortada=nth_ventana(1,1:tamano_ventana);
  #  overlap=[nth_ventana(1,tamano_ventana+1:tamano_convolucion),zeros_aggregate];
  #  ventanas_combinadas=[ventanas_combinadas,nth_ventana_recortada];
  #end  
end
