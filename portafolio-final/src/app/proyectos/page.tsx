// src/app/proyectos/page.tsx
"use client";

import Image from "next/image";
import Link from "next/link";
import { useState } from "react";

export default function ProyectosPage() {
  const [showHelp, setShowHelp] = useState(false);

  return (
    <main className="min-h-screen w-full overflow-x-hidden relative">
      {/* Fondo cielo */}
      <div
        className="absolute inset-0 -z-10 bg-cover bg-center"
        style={{ backgroundImage: 'url("/assets/cielo.jpg")' }}
        aria-hidden
      />

      {/* Cabecera */}
      <header className="px-4 pt-10 pb-6">
        <div className="mx-auto max-w-6xl">
          <div className="mx-auto w-[min(820px,92vw)] bg-[#1f4875] border-8 border-black rounded-md shadow-[0_12px_0_#000]">
            <h1 className="text-center text-white font-[PressStart] text-[28px] py-6 tracking-wide">
              MIS PROYECTOS
            </h1>
          </div>
        </div>
      </header>

      {/* Rejilla de proyectos */}
      <section className="mx-auto max-w-6xl px-4 pb-12">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-10 md:gap-12 place-items-center">
          <ProjectCard title="Proyecto 1" img="/assets/sala-cine.png" />
          <ProjectCard title="Proyecto 2" img="/assets/pantalla-mision.png" />
          <ProjectCard title="Proyecto 3" img="/assets/habitacion-gamer.png" />
        </div>

        {/* Botones inferiores */}
        <div className="mt-10 flex items-center justify-center gap-10">
          <PixelBrownButton as={Link} href="/">
            VOLVER
          </PixelBrownButton>

          <PixelBrownButton as="a" href="#" onClick={(e: any) => e.preventDefault()}>
            DESCARGAR
          </PixelBrownButton>
        </div>
      </section>

      {/* Signo de interrogación con globito */}
      <div
        className="fixed right-4 md:right-6 bottom-6 z-30 animate-bob cursor-pointer flex items-center gap-3"
        onClick={() => setShowHelp(!showHelp)}
      >
       {/* Globito blanco que aparece al hacer click */}
{showHelp && (
  <div className="bg-white text-black border-8 border-black rounded-md px-6 py-5 shadow-[0_8px_0_#000] font-[PressStart] text-[25px] leading-relaxed w-[380px]">
    Aquí verás mis proyectos. <br />
    Pasa el cursor por encima <br />
    y haz clic para conocerlos.
  </div>
)}


        <Image
          src="/assets/question.png"
          alt="Ayuda"
          width={46}
          height={64}
          style={{ imageRendering: "pixelated" }}
          priority
        />
      </div>

      {/* Animaciones locales */}
      <style jsx>{`
        @keyframes bob {
          0% { transform: translateY(0); }
          50% { transform: translateY(-6px); }
          100% { transform: translateY(0); }
        }
        .animate-bob {
          animation: bob 1.4s ease-in-out infinite;
        }
      `}</style>
    </main>
  );
}

/* ========= Componentes auxiliares ========= */

function ProjectCard({ title, img }: { title: string; img: string }) {
  return (
    <div className="relative w-[290px]">
      <div
        className="
          relative mx-auto w-[290px]
          bg-[#0f2a37] border-8 border-black rounded-md
          shadow-[0_14px_0_#000] px-3 pt-3 pb-5
          transition-transform duration-150 ease-out
          hover:scale-[1.06]
        "
        style={{ imageRendering: "pixelated" }}
      >
        <div className="border-8 border-black rounded-md bg-[#123141] p-2">
          <div className="overflow-hidden border-4 border-black rounded">
            <Image
              src={img}
              alt={title}
              width={260}
              height={200}
              className="block"
              style={{ imageRendering: "pixelated" }}
            />
          </div>
        </div>

        <p className="mt-3 text-center text-[12px] font-[PressStart] text-[#ffd54a]">
          {title}
        </p>
      </div>
    </div>
  );
}

function PixelBrownButton({
  as = "button",
  href,
  onClick,
  children,
}: {
  as?: any;
  href?: string;
  onClick?: (e: any) => void;
  children: React.ReactNode;
}) {
  const Comp = as as any;
  return (
    <Comp
      href={href}
      onClick={onClick}
      className="
        inline-block
        bg-[#6e3a06] text-white
        border-8 border-black rounded-md
        shadow-[0_10px_0_#000]
        px-8 py-3
        font-[PressStart] text-[16px] tracking-wide
        hover:translate-y-0.5 hover:shadow-[0_8px_0_#000]
        active:translate-y-1 active:shadow-[0_6px_0_#000]
        transition-transform
      "
    >
      {children}
    </Comp>
  );
}
