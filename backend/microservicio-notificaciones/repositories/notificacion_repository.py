class NotificacionRepositorio:
    def __init__(self):
        self.db = {}

    def guardar(self, notificacion):
        id_notificacion = len(self.db) + 1
        self.db[id_notificacion] = notificacion
        return notificacion

    def buscar_por_id(self, id):
        return self.db.get(id, None)
