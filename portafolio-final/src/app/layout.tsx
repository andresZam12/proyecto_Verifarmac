import "./globals.css";
import type { Metadata } from "next";
import { Press_Start_2P } from "next/font/google";

const press = Press_Start_2P({ subsets: ["latin"], weight: "400" });

export const metadata: Metadata = {
  title: "Portafolio | Deivid",
  description: "Portafolio estilo videojuego 2D pixelado – Next.js + TS + Tailwind",
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <body className={press.className}>{children}</body>
    </html>
  );
}
