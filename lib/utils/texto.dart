/// Normaliza un texto para búsquedas: minúsculas y sin acentos.
String normalizarTexto(String texto) {
  const conAcento = 'áàäâãéèëêíìïîóòöôõúùüûñç';
  const sinAcento = 'aaaaaeeeeiiiiooooouuuunc';

  var resultado = texto.toLowerCase().trim();

  for (var i = 0; i < conAcento.length; i++) {
    resultado = resultado.replaceAll(conAcento[i], sinAcento[i]);
  }

  return resultado;
}
