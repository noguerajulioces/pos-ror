import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  print(event) {
    event.preventDefault();
    // Utiliza querySelector sobre this.element
    const ticketContent = this.element.querySelector("#ticket-content");
    if (!ticketContent) {
      alert("No se encontró el contenido del ticket");
      return;
    }
    const content = ticketContent.innerHTML;

    const printWindow = window.open("", "", "width=600,height=600");
    printWindow.document.write(`
      <html>
        <head>
          <title>Ticket</title>
          <style>
            /* Estilos para el ticket */
            body { font-family: sans-serif; padding: 20px; }
          </style>
        </head>
        <body>
          ${content}
        </body>
      </html>
    `);
    printWindow.document.close();
    printWindow.focus();
    printWindow.print();
    printWindow.close();
  }
}
