import tkinter as tk
from tkinter import messagebox, ttk
from config import APODERADO_DB_USER, APODERADO_DB_PASS, SECRETARIA_DB_USER, COLOR_SUCCESS
from database import DatabaseManager


class LoginView(ttk.Frame):
    def __init__(self, parent, on_login_success):
        super().__init__(parent, padding=35)
        self.on_login_success = on_login_success
        self.pack(expand=True)
        self._construir_ui()

    def _construir_ui(self):
        ttk.Label(self, text="MatriCore", style="Header.TLabel").pack(pady=(0, 5))
        ttk.Label(self, text="Sistema de gestion de matricula", style="SubHeader.TLabel").pack(pady=(0, 20))

        self.var_rol = tk.StringVar(value="Apoderado")
        frame_roles = ttk.Frame(self)
        frame_roles.pack(pady=10)

        ttk.Radiobutton(
            frame_roles, text="Apoderado (DNI)", variable=self.var_rol,
            value="Apoderado", command=self._actualizar_etiqueta
        ).pack(side=tk.LEFT, padx=12)

        ttk.Radiobutton(
            frame_roles, text="Secretaría (Admin)", variable=self.var_rol,
            value="Secretaria", command=self._actualizar_etiqueta
        ).pack(side=tk.LEFT, padx=12)

        self.lbl_credencial = ttk.Label(self, text="Documento Nacional de Identidad (DNI):")
        self.lbl_credencial.pack(anchor="w", pady=(15, 2))

        self.entry_credencial = ttk.Entry(self, font=("Segoe UI", 12), width=28, justify="center")
        self.entry_credencial.pack(pady=8)
        self.entry_credencial.focus()
        self.entry_credencial.bind('<Return>', lambda event: self._validar())

        btn_login = tk.Button(
            self, text="INGRESAR AL SISTEMA", command=self._validar,
            bg=COLOR_SUCCESS, fg="white", font=("Segoe UI", 10, "bold"),
            relief="flat", padx=25, pady=7, cursor="hand2"
        )
        btn_login.pack(pady=20)

    def _actualizar_etiqueta(self):
        self.entry_credencial.delete(0, tk.END)
        if self.var_rol.get() == "Apoderado":
            self.lbl_credencial.config(text="Documento Nacional de Identidad (DNI):")
            self.entry_credencial.config(show="")
        else:
            self.lbl_credencial.config(text="Contraseña del Rol Secretaría:")
            self.entry_credencial.config(show="*")

    def _validar(self):
        valor = self.entry_credencial.get().strip()
        rol = self.var_rol.get()

        if not valor:
            messagebox.showwarning("Campo Vacío", "Por favor ingrese su credencial.")
            return

        if rol == "Secretaria":
            exito, mensaje = DatabaseManager.autenticar_secretaria(valor)
            if exito:
                messagebox.showinfo("Acceso Administrativo", mensaje)
                self.on_login_success(
                    rol="Secretaria",
                    credenciales=(SECRETARIA_DB_USER, valor),
                    dni_apod=None
                )
            else:
                messagebox.showerror("Acceso Denegado", mensaje)
            return

        if len(valor) != 8 or not valor.isdigit():
            messagebox.showwarning("Formato Inválido", "El DNI debe contener exactamente 8 dígitos numéricos.")
            return

        exito, info = DatabaseManager.autenticar_apoderado(valor)
        if exito:
            messagebox.showinfo("Bienvenido(a)", f"Acceso concedido:\n{info}")
            self.on_login_success(
                rol="Apoderado",
                credenciales=(APODERADO_DB_USER, APODERADO_DB_PASS),
                dni_apod=valor
            )
        else:
            messagebox.showerror("Acceso Denegado", info)