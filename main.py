import tkinter as tk
from tkinter import ttk
from config import COLOR_BG, COLOR_PRIMARY, COLOR_SECONDARY
from ui_login import LoginView
from ui_dashboard import DashboardView


class SalleNetApp:
    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("MatriCore")
        self.root.geometry("950x620")
        self.root.configure(bg=COLOR_BG)

        self._configurar_estilos()

        self.container = ttk.Frame(self.root, padding=20)
        self.container.pack(fill=tk.BOTH, expand=True)

        self.mostrar_login()

    def _configurar_estilos(self):
        style = ttk.Style()
        style.theme_use('clam')
        style.configure("TFrame", background=COLOR_BG)
        style.configure("TLabelframe", background=COLOR_BG)
        style.configure("TLabelframe.Label", background=COLOR_BG, font=("Segoe UI", 9, "bold"), foreground=COLOR_SECONDARY)
        style.configure("TLabel", background=COLOR_BG, font=("Segoe UI", 10))
        style.configure("Header.TLabel", font=("Segoe UI", 16, "bold"), foreground=COLOR_PRIMARY)
        style.configure("SubHeader.TLabel", font=("Segoe UI", 10, "italic"), foreground="#576574")
        style.configure("TRadiobutton", background=COLOR_BG, font=("Segoe UI", 10, "bold"))
        style.configure("Treeview.Heading", font=("Segoe UI", 10, "bold"), background=COLOR_SECONDARY, foreground="white")
        style.configure("Treeview", font=("Segoe UI", 10), rowheight=26)

    def _limpiar_contenedor(self):
        for widget in self.container.winfo_children():
            widget.destroy()

    def mostrar_login(self):
        self._limpiar_contenedor()
        LoginView(self.container, on_login_success=self.mostrar_dashboard)

    def mostrar_dashboard(self, rol: str, credenciales: tuple, dni_apod: str):
        self._limpiar_contenedor()
        DashboardView(
            self.container,
            rol=rol,
            credenciales=credenciales,
            dni_apod=dni_apod,
            on_logout=self.mostrar_login
        )


if __name__ == "__main__":
    root = tk.Tk()
    app = SalleNetApp(root)
    root.mainloop()