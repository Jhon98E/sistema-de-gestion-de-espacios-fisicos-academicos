TEMPLATES_EMAIL = {
    "registro_usuario": """
Hola {nombre_completo},

¡Bienvenido al Sistema de Gestión de Espacios!

Tu cuenta ha sido creada exitosamente con los siguientes datos:
- Código de usuario: {codigo_usuario}
- Email: Este correo electrónico

Ya puedes iniciar sesión en el sistema usando tu código de usuario y la contraseña que estableciste.

¡Esperamos que tengas una excelente experiencia usando nuestro sistema!

Saludos,
Equipo de Gestión de Espacios
    """,
    
    "recuperacion_password": """
Hola {nombre_completo},

Has solicitado recuperar tu contraseña en el Sistema de Gestión de Espacios.

Para establecer una nueva contraseña, utiliza el siguiente código de recuperación:
{token_recuperacion}

Este código es válido por 15 minutos por seguridad.

Si no solicitaste esta recuperación, puedes ignorar este correo.

Saludos,
Equipo de Gestión de Espacios
    """,
    
    "horario": """
Hola {nombre_completo},

Te informamos que un horario ha sido {accion} en el Sistema de Gestión de Espacios.

Detalles del horario:
{detalles}

Para más información, ingresa al sistema y revisa tus horarios.

Saludos,
Equipo de Gestión de Espacios
    """
}