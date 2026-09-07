const INTERVALO_HITO = 50;

function doGet() {
  return respuesta_({ ok: true, servicio: "notificaciones" });
}

function doPost(e) {
  try {
    const datos = JSON.parse((e && e.postData && e.postData.contents) || "{}");
    const titulo = String(datos.titulo || "Contador de salchichas").trim();
    const mensaje = String(datos.mensaje || "").trim();

    if (!mensaje) {
      return respuesta_({ ok: false, error: "Falta el mensaje" });
    }

    return respuesta_(enviarNotificacion_(titulo, mensaje));
  } catch (error) {
    return respuesta_({ ok: false, error: String(error) });
  }
}

function enviarHito(total) {
  const numero = Number(total);
  if (!Number.isInteger(numero) || numero <= 0 || numero % INTERVALO_HITO !== 0) {
    throw new Error("El total debe ser un múltiplo positivo de " + INTERVALO_HITO);
  }

  return enviarNotificacion_(
    "¡Nuevo hito salchicha!",
    "¡Llegaron a los " + numero + " salchichas! 🐾"
  );
}

function enviarNotificacion_(titulo, mensaje) {
  const propiedades = PropertiesService.getScriptProperties();
  const proyecto = propiedades.getProperty("FIREBASE_PROJECT_ID");
  const tema = propiedades.getProperty("FCM_TOPIC");

  if (!proyecto || !tema) {
    throw new Error("Configura FIREBASE_PROJECT_ID y FCM_TOPIC en las propiedades del script");
  }

  const url = "https://fcm.googleapis.com/v1/projects/" + encodeURIComponent(proyecto) + "/messages:send";
  const carga = {
    message: {
      topic: tema,
      notification: { title: titulo, body: mensaje },
      android: {
        priority: "high",
        notification: { channel_id: "salchichas_notificaciones" }
      },
      data: { origen: "contador_salchichas" }
    }
  };

  const respuesta = UrlFetchApp.fetch(url, {
    method: "post",
    contentType: "application/json",
    headers: { Authorization: "Bearer " + ScriptApp.getOAuthToken() },
    payload: JSON.stringify(carga),
    muteHttpExceptions: true
  });

  const codigo = respuesta.getResponseCode();
  const cuerpo = respuesta.getContentText();
  if (codigo < 200 || codigo >= 300) {
    throw new Error("FCM respondió " + codigo + ": " + cuerpo);
  }

  return { ok: true, codigo: codigo };
}

function respuesta_(contenido) {
  return ContentService
    .createTextOutput(JSON.stringify(contenido))
    .setMimeType(ContentService.MimeType.JSON);
}
