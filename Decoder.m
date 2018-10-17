function Decoder()
  filename='output.wav';
  [input_music_array,Fs]=audioread(filename);
  str_parametros=json_decoder('parametros_usuario.json',"Se utilizaran los siguientes parametros");
  parametros_usuario=set_parametros_codificacion(str_parametros);
  disp("Inicializando la generacion de ventanas");
  ventanas= creador_de_ventanas(input_music_array,parametros_usuario(1));   
  disp("realizando la autocorrelacion");
  
  
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
  a1= str2num(strsplit(Parametros_substring{1,3},':'){2});
  a0= str2num(strsplit(Parametros_substring{1,4},':'){2});
  t1= str2num(strsplit(Parametros_substring{1,5},':'){2});
  t0= str2num(strsplit(Parametros_substring{1,6},':'){2});
  params=[M,N,a1,a0,t1,t0];
end

