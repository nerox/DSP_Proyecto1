function Decoder()
  SampleSize=316;
  filename='Herida_32bits.wav';
  [input_music_array,Fs]=audioread(filename);
  v= creador_de_ventanas(input_music_array,SampleSize)  
end

function vetanas_reducidas = creador_de_ventanas(input_music_array, tamano_ventana)
  tamano_input=length(input_music_array);
  cantidad_de_ventanas=tamano_input/tamano_ventana;
  disp(cantidad_de_ventanas);
  vetanas_reducidas=ceil(cantidad_de_ventanas);
  while
  nueva_ventana=[];
  
end 

