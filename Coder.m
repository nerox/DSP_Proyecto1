function Coder()
  filename='Herida_32bits.wav';
  [input_music_array,Fs]=audioread(filename);
  
  disp("Inicializacion de metadatos, a cada pregunta ingrese el texto. En caso de no querer agregar el dato, solo presione ENTER");
  metadatos=insertarMetadatos();
  parametros_usuario=set_parametros_codificacion();
  disp("Inicializando la generacion de ventanas");
  ventanas= creador_de_ventanas(input_music_array,parametros_usuario(1)); 
  disp("realizando el multiplexado");
  [cantidad_de_ventanas,tamano_ventana] = size(ventanas);
  ventanas_multiplexadas=multiplexado(ventanas,metadatos,parametros_usuario,cantidad_de_ventanas);
  disp("implementando la combinacion de ventanas");
  ventanas_combinadas=combinacion_ventanas(ventanas_multiplexadas,parametros_usuario,cantidad_de_ventanas);
  #output_array=generate_audio_array(ventanas_combinadas);
  disp("generando el audio de salida");
  audiowrite("output.wav",ventanas_combinadas,Fs);  
end

#funcion de prueba para verificar que al unir ventanas se genera el audio de entrada
function output_array=generate_audio_array(inputarray)
  [rows,columns] = size(inputarray);
  output_array=[];
  for(index=1:rows)
    output_array=[output_array,inputarray(index,:)];
  end
end

function metadatos=insertarMetadatos()
  metadatos_string="";
  prompt = 'Digite el nombre de artista ';
  metadatos_string = recibir_datos(prompt,metadatos_string," Artista:");
  prompt = 'Digite el titulo de la cancion ';
  metadatos_string = recibir_datos(prompt,metadatos_string," Titulo:");
  prompt = 'Digite el autor de la pieza ';
  metadatos_string = recibir_datos(prompt,metadatos_string," Autor:");   
  prompt = 'Digite el nombre del album ';
  metadatos_string = recibir_datos(prompt,metadatos_string," Album:");   
  prompt = 'Digite el a de publicacion ';
  metadatos_string = recibir_datos(prompt,metadatos_string," Publicacion:");
  prompt = 'Digite el nombre del artista invitado ';
  metadatos_string = recibir_datos(prompt,metadatos_string," Invitado:");
  prompt = 'Digite el nombre del productor ';
  metadatos_string = recibir_datos(prompt,metadatos_string," Productor:");   
  originalword =  toascii(metadatos_string);
  disp(originalword);
  metadatos="";
  for i=1:length(originalword)
    metadatos = strcat(metadatos,dec2bin(originalword(i)));
  end
end

function metadatos_string=recibir_datos(input_data,metadatos_string_input,key)
  s=input(input_data,"s"); 
  metadatos_string=strcat(metadatos_string_input,key);  
  metadatos_string=strcat(metadatos_string_input,s);
end

function vetanas_reducidas = creador_de_ventanas(input_music_array, tamano_ventana)
  tamano_input=length(input_music_array);
  disp(length(input_music_array));
  cantidad_de_ventanas=tamano_input/tamano_ventana;
  vetanas_reducidas_fixed=floor(cantidad_de_ventanas);
  disp(vetanas_reducidas_fixed);
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

function params=set_parametros_codificacion()
  M= input("ingrese el tamano M de las ventanas "); 
  N= input("ingrese el tamano N de la respuesta al impulso "); 
  a1= input("ingrese el valor de a1 para codificar 1's ");
  a0= input("ingrese el valor de a0 para codificar 0's ");
  t1= input("ingrese el valor de t1 para codificar 1's ");
  t0= input("ingrese el valor de t0 para codificar 0's ");
  params=[M,N,a1,a0,t1,t0];
end

function ventanas_multiplexadas=multiplexado(ventanas,metadatos,parametros_usuario,cantidad_de_ventanas)
  tamano_respuesta_impulso=parametros_usuario(2);
  a0=parametros_usuario(4);
  a1=parametros_usuario(3);  
  t0=parametros_usuario(6);
  t1=parametros_usuario(5);  
  ventanas_multiplexadas=[];  
  for(index_multiplexado=1:cantidad_de_ventanas)
    respuesta_impulso=zeros(1,tamano_respuesta_impulso); 
    ventana_codificada=[]; 
    if(index_multiplexado<=length(metadatos))
      if(metadatos(index_multiplexado)==0)
        respuesta_impulso(1)=a0;
        respuesta_impulso(t0)=1;
        ventana_codificada=conv(ventanas(index_multiplexado,:),respuesta_impulso);
      else
        respuesta_impulso(1)=a1;
        respuesta_impulso(t1)=1;
        ventana_codificada=conv(ventanas(index_multiplexado,:),respuesta_impulso);
      end
      #ventanas_multiplexadas=[ventanas_multiplexadas;ventana_codificada];
    else
      respuesta_impulso(1)=a0;
      respuesta_impulso(t0)=1;
      ventana_codificada=conv(ventanas(index_multiplexado,:),respuesta_impulso);
      #ventanas_multiplexadas=[ventanas_multiplexadas;ventana_codificada];
    end
    ventanas_multiplexadas=[ventanas_multiplexadas;ventana_codificada];
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
  for(index_multiplexado=2:cantidad_de_ventanas)
    nth_ventana=overlap+ventanas_multiplexadas(index_multiplexado,:);
    nth_ventana_recortada=nth_ventana(1,1:tamano_ventana);
    overlap=[nth_ventana(1,tamano_ventana+1:tamano_convolucion),zeros_aggregate];
    ventanas_combinadas=[ventanas_combinadas,nth_ventana_recortada];
  end  
end
