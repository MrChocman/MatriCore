import tkinter as tk
from tkinter import messagebox, ttk
import psycopg2
from config import (
    GRADOS_COLEGIO, ESTADOS_MATRICULA, COLOR_BG,
    COLOR_INFO, COLOR_WARNING, COLOR_DANGER, COLOR_MUTED, COLOR_SUCCESS, COLOR_SECONDARY
)
from database import DatabaseManager
from ui_reportes import ReportesModal


class DashboardView(ttk.Frame):

    def __init__(self, parent, rol: str, credenciales: tuple, dni_apod: str, on_logout):
        super().__init__(parent)
        self.rol = rol
        self.credenciales = credenciales
        self.dni_apod = dni_apod
        self.on_logout = on_logout
        self.pack(fill=tk.BOTH, expand=True)

        self._construir_ui()
        self.cargar_datos()

    def _construir_ui(self):
        header_frame = ttk.Frame(self)
        header_frame.pack(fill=tk.X, pady=(0, 10))

        titulo = (
            "Panel Administrativo - Listado General de Matrículas"
            if self.rol == "Secretaria"
            else "Portal Familiar - Estado de Matrícula de sus Hijos"
        )
        ttk.Label(header_frame, text=titulo, style="Header.TLabel").pack(side=tk.LEFT)

        tk.Button(
            header_frame, text="Cerrar Sesión", command=self.on_logout,
            bg="#e74c3c", fg="white", font=("Segoe UI", 9, "bold"),
            relief="flat", padx=12, pady=4, cursor="hand2"
        ).pack(side=tk.RIGHT)

        info_rol = f"Conectado como: {self.credenciales[0]}"
        ttk.Label(self, text=info_rol, style="SubHeader.TLabel").pack(anchor="w", pady=(0, 10))

        if self.rol == "Secretaria":
            filtro_frame = ttk.LabelFrame(self, text="Filtros de Búsqueda Rápida", padding=10)
            filtro_frame.pack(fill=tk.X, pady=(0, 12))

            ttk.Label(filtro_frame, text="Buscar por DNI Alumno:").pack(side=tk.LEFT, padx=(5, 5))
            self.entry_buscar_dni = ttk.Entry(filtro_frame, width=15, font=("Segoe UI", 10))
            self.entry_buscar_dni.pack(side=tk.LEFT, padx=(0, 15))
            self.entry_buscar_dni.bind('<Return>', lambda e: self.cargar_datos())

            ttk.Label(filtro_frame, text="Filtrar por Estado:").pack(side=tk.LEFT, padx=(5, 5))
            self.combo_filtro_estado = ttk.Combobox(
                filtro_frame,
                values=["Todos", "Pendiente", "Matriculado", "Anulado", "No Matriculado"],
                state="readonly", width=18
            )
            self.combo_filtro_estado.current(0)
            self.combo_filtro_estado.pack(side=tk.LEFT, padx=(0, 15))

            tk.Button(
                filtro_frame, text="Buscar", command=self.cargar_datos,
                bg=COLOR_SECONDARY, fg="white", font=("Segoe UI", 9, "bold"),
                relief="flat", padx=14, pady=3, cursor="hand2"
            ).pack(side=tk.LEFT, padx=5)

            tk.Button(
                filtro_frame, text="Limpiar Filtros", command=self._limpiar_filtros,
                bg="#95a5a6", fg="white", font=("Segoe UI", 9, "bold"),
                relief="flat", padx=10, pady=3, cursor="hand2"
            ).pack(side=tk.LEFT, padx=5)

        columnas = ("ID Matrícula", "DNI Alumno", "Estudiante", "Año", "Grado", "Estado", "Nro. Operación")
        self.tree = ttk.Treeview(self, columns=columnas, show="headings", height=11)

        anchos = [110, 85, 220, 60, 130, 110, 110]
        for col, ancho in zip(columnas, anchos):
            self.tree.heading(col, text=col)
            self.tree.column(col, width=ancho, anchor="center")

        self.tree.pack(fill=tk.BOTH, expand=True)

        acciones_frame = ttk.LabelFrame(self, text="Operaciones Disponibles", padding=12)
        acciones_frame.pack(fill=tk.X, pady=15)

        tk.Button(
            acciones_frame, text="Registrar Matrícula", command=self._abrir_modal_registro,
            bg=COLOR_INFO, fg="white", font=("Segoe UI", 9, "bold"),
            relief="flat", padx=12, pady=5, cursor="hand2"
        ).pack(side=tk.LEFT, padx=5)

        if self.rol == "Secretaria":
            tk.Button(
                acciones_frame, text="Validar / Modificar", command=self._abrir_modal_edicion,
                bg=COLOR_WARNING, fg="white", font=("Segoe UI", 9, "bold"),
                relief="flat", padx=12, pady=5, cursor="hand2"
            ).pack(side=tk.LEFT, padx=5)

            tk.Button(
                acciones_frame, text="Anular", command=self._anular_registro,
                bg=COLOR_DANGER, fg="white", font=("Segoe UI", 9, "bold"),
                relief="flat", padx=12, pady=5, cursor="hand2"
            ).pack(side=tk.LEFT, padx=5)

            tk.Button(
                acciones_frame, text="Reportes", command=lambda: ReportesModal(self, self.credenciales),
                bg="#8e44ad", fg="white", font=("Segoe UI", 9, "bold"),
                relief="flat", padx=12, pady=5, cursor="hand2"
            ).pack(side=tk.LEFT, padx=5)

        tk.Button(
            acciones_frame, text="Actualizar", command=self.cargar_datos,
            bg=COLOR_MUTED, fg="white", font=("Segoe UI", 9, "bold"),
            relief="flat", padx=10, pady=5, cursor="hand2"
        ).pack(side=tk.RIGHT, padx=5)

    def _limpiar_filtros(self):
        if self.rol == "Secretaria":
            self.entry_buscar_dni.delete(0, tk.END)
            self.combo_filtro_estado.current(0)
            self.cargar_datos()

    def cargar_datos(self):
        for item in self.tree.get_children():
            self.tree.delete(item)

        filtro_dni = self.entry_buscar_dni.get().strip() if self.rol == "Secretaria" else ""
        filtro_estado = self.combo_filtro_estado.get() if self.rol == "Secretaria" else "Todos"

        try:
            filas = DatabaseManager.obtener_matriculas(
                self.credenciales, self.rol, self.dni_apod, filtro_dni, filtro_estado
            )
            for fila in filas:
                self.tree.insert("", tk.END, values=fila)
        except Exception as e:
            messagebox.showerror("Error SQL", str(e))

    def _abrir_modal_registro(self):
        vent = tk.Toplevel(self)
        vent.title("Registrar Nueva Matrícula")
        vent.geometry("450x420")
        vent.transient(self.winfo_toplevel())
        vent.grab_set()
        vent.configure(bg=COLOR_BG)

        ttk.Label(vent, text="Registro de Matrícula", style="Header.TLabel").pack(pady=(15, 5))
        ttk.Label(vent, text="Validación automática de recaudación bancaria", style="SubHeader.TLabel").pack(pady=(0, 15))

        ttk.Label(vent, text="Estudiante (DNI - Nombre):").pack()
        combo_est = ttk.Combobox(vent, width=42, state="readonly")
        combo_est.pack(pady=5)

        try:
            lista_est = DatabaseManager.obtener_estudiantes_disponibles(self.credenciales, self.rol, self.dni_apod)
            combo_est['values'] = lista_est
            if lista_est:
                combo_est.current(0)
        except Exception as e:
            messagebox.showerror("Error", f"No se pudo cargar estudiantes:\n{e}")

        ttk.Label(vent, text="Pago Conciliado Disponible:").pack(pady=(10, 0))
        pagos_detectados = []
        try:
            pagos_detectados = DatabaseManager.obtener_pagos_disponibles(self.credenciales, self.rol, self.dni_apod)
        except Exception as e:
            messagebox.showerror("Error SQL", f"Error al verificar pagos:\n{e}")

        combo_pagos = ttk.Combobox(vent, width=42, state="readonly")
        combo_pagos.pack(pady=5)

        ttk.Label(vent, text="Año Académico:").pack(pady=(10, 0))
        entry_anio = ttk.Entry(vent, width=45)
        entry_anio.insert(0, "2027")
        entry_anio.pack(pady=5)

        ttk.Label(vent, text="Grado a Matricular:").pack(pady=(10, 0))
        combo_grado = ttk.Combobox(vent, values=GRADOS_COLEGIO, state="readonly", width=42)
        combo_grado.current(0)
        combo_grado.pack(pady=5)

        def guardar():
            sel_est = combo_est.get()
            sel_pago = combo_pagos.get()
            anio = entry_anio.get().strip()
            grado = combo_grado.get()

            if not all([sel_est, sel_pago, anio, grado]) or not anio.isdigit():
                messagebox.showwarning("Validación", "Complete todos los campos correctamente.")
                return

            dni_est = sel_est.split(" - ")[0].strip()
            nro_op = sel_pago.split(" | ")[0].strip()

            try:
                id_matri = DatabaseManager.registrar_matricula_acid(
                    self.credenciales, dni_est, nro_op, int(anio), grado
                )
                messagebox.showinfo(
                    "Transacción Exitosa",
                    f"Matrícula {id_matri} registrada correctamente.\n"
                    "Estado inicial: Pendiente de revisión documental.\n"
                    
                )
                vent.destroy()
                self.cargar_datos()
            except psycopg2.Error as e:
                messagebox.showerror("Error de Integridad / BD", f"No se pudo completar la transacción:\n{e.pgerror}")

        btn_procesar = tk.Button(
            vent, text="PROCESAR MATRÍCULA", command=guardar,
            bg=COLOR_SUCCESS, fg="white", relief="flat",
            font=("Segoe UI", 10, "bold"), padx=20, pady=6, cursor="hand2"
        )
        btn_procesar.pack(pady=18)

        if pagos_detectados:
            combo_pagos['values'] = pagos_detectados
            combo_pagos.current(0)
        else:
            combo_pagos['values'] = ["Sin pagos conciliados disponibles"]
            combo_pagos.current(0)
            combo_pagos.config(state="disabled")
            btn_procesar.config(state="disabled", bg=COLOR_MUTED, cursor="arrow")
            messagebox.showwarning(
                "Pago no detectado",
                "No se encontraron pagos conciliados disponibles para su cuenta.\n\n"
                "Si realizó su pago recientemente en agente o banca móvil, espere la validación bancaria e intente nuevamente."
            )

    def _abrir_modal_edicion(self):
        seleccion = self.tree.selection()
        if not seleccion:
            messagebox.showwarning("Atención", "Seleccione una fila de la tabla para modificar.")
            return

        valores = self.tree.item(seleccion[0], "values")
        id_matri = valores[0]

        if id_matri == 'Sin Trámite':
            messagebox.showinfo("Operación Inválida", "El estudiante seleccionado aún no tiene una matrícula registrada.")
            return

        vent_edit = tk.Toplevel(self)
        vent_edit.title("Validar y Actualizar Matrícula")
        vent_edit.geometry("400x320")
        vent_edit.transient(self.winfo_toplevel())
        vent_edit.grab_set()
        vent_edit.configure(bg=COLOR_BG)

        ttk.Label(vent_edit, text=f"Expediente: {id_matri}", style="Header.TLabel").pack(pady=(15, 5))
        ttk.Label(vent_edit, text=f"Alumno: {valores[2]}", style="SubHeader.TLabel").pack(pady=(0, 15))

        ttk.Label(vent_edit, text="Grado Asignado:").pack()
        combo_grado = ttk.Combobox(vent_edit, values=GRADOS_COLEGIO, state="readonly", width=30)
        if valores[4] in GRADOS_COLEGIO:
            combo_grado.set(valores[4])
        else:
            combo_grado.current(0)
        combo_grado.pack(pady=5)

        ttk.Label(vent_edit, text="Estado Oficial del Trámite:").pack(pady=(10, 0))
        combo_estado = ttk.Combobox(vent_edit, values=ESTADOS_MATRICULA, state="readonly", width=30)
        combo_estado.set(valores[5])
        combo_estado.pack(pady=5)

        def actualizar():
            nuevo_grado = combo_grado.get()
            nuevo_estado = combo_estado.get()
            try:
                DatabaseManager.actualizar_matricula(self.credenciales, id_matri, nuevo_grado, nuevo_estado)
                messagebox.showinfo(
                    "Actualización Exitosa",
                    f"La matrícula {id_matri} ahora figura como '{nuevo_estado}' (Procedimiento SP ejecutado)."
                )
                vent_edit.destroy()
                self.cargar_datos()
            except psycopg2.Error as e:
                messagebox.showerror("Error de Privilegios / SQL", str(e.pgerror))

        tk.Button(
            vent_edit, text="GUARDAR CAMBIOS", command=actualizar,
            bg=COLOR_WARNING, fg="white", relief="flat",
            font=("Segoe UI", 10, "bold"), padx=20, pady=6, cursor="hand2"
        ).pack(pady=20)

    def _anular_registro(self):
        seleccion = self.tree.selection()
        if not seleccion:
            messagebox.showwarning("Atención", "Seleccione una matrícula de la tabla para anular.")
            return

        valores = self.tree.item(seleccion[0], "values")
        id_matri = valores[0]
        if id_matri == 'Sin Trámite':
            return

        confirmacion = messagebox.askyesno(
            "Confirmar Borrado",
            f"¿Desea anular el expediente {id_matri}?\n\n"
            "El registro pasará a estado 'Anulado'"
        )
        if confirmacion:
            try:
                DatabaseManager.anular_matricula_logico(self.credenciales, id_matri)
                messagebox.showinfo("Borrado Lógico Completado", f"El expediente {id_matri} fue marcado como 'Anulado'.")
                self.cargar_datos()
            except psycopg2.Error as e:
                messagebox.showerror("Error de Integridad / Privilegios", f"No se pudo anular el registro:\n{e.pgerror}")