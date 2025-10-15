// src/app/page.tsx
import Image from "next/image";
import Link from "next/link";

export default function Home() {
  return (
    <main className="relative min-h-screen overflow-x-hidden">
      {/* Fondo */}
      <div
        className="absolute inset-0 -z-10 bg-cover bg-center"
        style={{ backgroundImage: "url(/assets/bg-city.png)" }}
        aria-hidden
      />

      {/* Contenido centrado */}
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 pt-16 pb-24">
        {/* Fila principal: cartel + botones | avatar */}
        <div className="grid grid-cols-1 lg:grid-cols-[560px_1fr] items-start gap-8 lg:gap-16">
          {/* Columna izquierda */}
          <section className="w-full">
            {/* Cartucho de saludo */}
            <div className="mx-auto w-[560px] max-w-full bg-[#31256c] border-8 border-black shadow-[0_10px_0_#000] text-yellow-300 rounded-md">
              <p className="px-6 py-5 text-[26px] leading-tight font-[PressStart]">
                ¡Hola! ¿Listo para conocer mi portafolio personal?
              </p>
            </div>

            {/* Botones */}
            <div className="mt-6 space-y-5 w-[560px] max-w-full">
              {/* Aquí redirige al mapa */}
              <PixelButton href="/mapa" label="EMPEZAR" />
              <PixelButton href="/proyectos" label="PROYECTOS" />
              <PixelButton href="/acerca" label="ACERCA DE MI" />
              <PixelButton href="/opiniones" label="OPINIONES" />
              <PixelButton href="/timeline" label="LINEA DE TIEMPO" />
            </div>
          </section>

          {/* Columna derecha: avatar + nombre */}
          <section className="relative justify-self-center lg:justify-self-end mt-6 lg:mt-0 pt-20">
            {/* Cartel con nombre */}
            <div className="absolute top-0 left-1/2 -translate-x-1/2 z-20 w-[320px]">
              <div className="animate-name-bob">
                <div
                  className="
                    w-full text-center
                    bg-[#31256c] text-yellow-300 font-press
                    border-8 border-black rounded-md
                    px-4 py-3 shadow-[0_12px_0_#000]
                    text-[22px] leading-tight
                  "
                >
                  <span className="block">Deivid</span>
                  <span className="block">Julian</span>
                </div>
              </div>
            </div>

            {/* Avatar con idle-bob */}
            <Image
              src="/assets/avatar-parado.png"
              alt="Avatar"
              width={420}
              height={420}
              priority
              className="select-none -mt-2 animate-bob"
            />
          </section>
        </div>

        {/* Contacto */}
        <div className="mt-10 grid grid-cols-1 md:grid-cols-2 gap-6 w-[880px] max-w-full">
          <ContactPanel>
            <span className="text-yellow-300">Contáctame :</span>{" "}
            <span className="text-white">316 895 7503</span>
          </ContactPanel>

          <ContactPanel>
            <span className="text-white">deividjulianalvarado@gmail.com</span>
          </ContactPanel>
        </div>
      </div>
    </main>
  );
}

/* ==== UI helpers ==== */
function PixelButton({ href, label }: { href: string; label: string }) {
  return (
    <Link
      href={href}
      className="
        block w-full text-center
        bg-[#2b93ff] text-yellow-300
        border-8 border-black rounded-md
        shadow-[0_10px_0_#000] 
        px-6 py-4 text-[26px] font-[PressStart] tracking-wide
        hover:translate-y-0.5 hover:shadow-[0_8px_0_#000]
        active:translate-y-1 active:shadow-[0_6px_0_#000]
        transition-transform
      "
    >
      {label}
    </Link>
  );
}

function ContactPanel({ children }: { children: React.ReactNode }) {
  return (
    <div
      className="
        bg-[#132533] border-8 border-black rounded-md
        shadow-[0_10px_0_#000] px-6 py-5
        text-[22px] font-[PressStart] tracking-wide
      "
    >
      {children}
    </div>
  );
}
