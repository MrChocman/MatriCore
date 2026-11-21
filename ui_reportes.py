import tkinter as tk
from tkinter import ttk, messagebox
from config import COLOR_BG, COLOR_PRIMARY
from database import DatabaseManager


LISTA_REPORTES = [
    "Alumnos matriculados con datos de apoderado y parentesco",
    "Consolidado financiero de recaudación por medio de pago",
    "Ficha médica, seguro y alergias de estudiantes matriculados",
    "Expedientes pendientes de validación documental con voucher",
    "Registro de boletas electrónicas emitidas por destinatario",
    "Estado de autorizaciones legales vinculadas por matrícula",
    "Directorio de contacto telefónico y domicilio por grado",
    "Estadística de población estudiantil por año, grado y estado",
    "Estado general de recaudación bancaria",
    "Bitácora de historial y control de cambios de matrícula"
]


class ReportesModal(tk.Toplevel):
    """Ventana modal para consultar y visualizar los 10 reportes de la base de datos."""

    def __init__(self, parent, credenciales: tuple):
        super().__init__(parent)
        self.credenciales = credenciales
        self.title("Módulo de Reportes Institucionales")
        self.geometry("880x480")
        self.transient(parent)
        self.grab_set()
        self.configure(bg=COLOR_BG)

        self._construir_ui()
        self.generar_reporte()

    def _construir_ui(self):
        ttk.Label(
            self,
            text="Reportes Institucionales",
            font=("Segoe UI", 14, "bold"),
            foreground=COLOR_PRIMARY
        ).pack(pady=(15, 2))

        ttk.Label(
            self,
            text="",
            font=("Segoe UI", 9, "italic"),
            foreground="#7f8c8d"
        ).pack(pady=(0, 12))

        control_frame = ttk.Frame(self, padding=(15, 5))
        control_frame.pack(fill=tk.X)

        ttk.Label(control_frame, text="Seleccionar Reporte:", font=("Segoe UI", 10, "bold")).pack(side=tk.LEFT, padx=(0, 10))

        self.combo_reportes = ttk.Combobox(
            control_frame, values=LISTA_REPORTES, state="readonly", width=85, font=("Segoe UI", 10)
        )
        self.combo_reportes.current(0)
        self.combo_reportes.pack(side=tk.LEFT, fill=tk.X, expand=True)
        self.combo_reportes.bind("<<ComboboxSelected>>", lambda e: self.generar_reporte())

        self.tabla_frame = ttk.Frame(self, padding=15)
        self.tabla_frame.pack(fill=tk.BOTH, expand=True)

        self.tree = ttk.Treeview(self.tabla_frame, show="headings", height=13)
        self.tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)

        scrollbar = ttk.Scrollbar(self.tabla_frame, orient="vertical", command=self.tree.yview)
        self.tree.configure(yscrollcommand=scrollbar.set)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)

        self.lbl_total = ttk.Label(self, text="Registros encontrados: 0", font=("Segoe UI", 9, "bold"))
        self.lbl_total.pack(anchor="e", padx=20, pady=(0, 12))

    def generar_reporte(self):
        indice = self.combo_reportes.current()
        try:
            columnas, filas = DatabaseManager.ejecutar_reporte(self.credenciales, indice)

            for item in self.tree.get_children():
                self.tree.delete(item)

            self.tree["columns"] = columnas
            ancho_col = max(110, int(810 / len(columnas)))
            for col in columnas:
                self.tree.heading(col, text=col)
                self.tree.column(col, width=ancho_col, anchor="center")

            for fila in filas:
                self.tree.insert("", tk.END, values=fila)

            self.lbl_total.config(text=f"Registros encontrados: {len(filas)}")
        except Exception as e:
            messagebox.showerror("Error al generar reporte", f"No se pudo ejecutar la consulta:\n{e}")