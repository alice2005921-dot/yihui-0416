function getOverlay() {
  return document.getElementById("navOverlay");
}

function setBodyLocked(locked) {
  document.body.classList.toggle("is-locked", locked);
}

function setMenuExpanded(isExpanded) {
  const btn = document.querySelector('[data-action="toggle-menu"]');
  if (!(btn instanceof HTMLButtonElement)) return;
  btn.setAttribute("aria-expanded", isExpanded ? "true" : "false");
}

function setOverlayOpen(isOpen) {
  const overlay = getOverlay();
  if (!overlay) return;
  overlay.classList.toggle("active", isOpen);
  setBodyLocked(isOpen);
  setMenuExpanded(isOpen);
}

function toggleOverlay() {
  const overlay = getOverlay();
  if (!overlay) return;
  const next = !overlay.classList.contains("active");
  setOverlayOpen(next);
}

function closeOverlay() {
  setOverlayOpen(false);
}

function ensureImageModal() {
  let modal = document.getElementById("imgModal");
  if (modal) return modal;

  modal = document.createElement("div");
  modal.id = "imgModal";
  modal.className = "img-modal";
  modal.setAttribute("role", "dialog");
  modal.setAttribute("aria-modal", "true");
  modal.setAttribute("aria-label", "圖片放大檢視");
  modal.innerHTML = `
    <div class="img-modal__inner">
      <img class="img-modal__img" alt="" />
      <div class="img-modal__caption" id="imgModalCaption"></div>
    </div>
  `;

  document.body.appendChild(modal);
  return modal;
}

function openImageModal(src, altText) {
  const modal = ensureImageModal();
  const img = modal.querySelector(".img-modal__img");
  const caption = modal.querySelector("#imgModalCaption");
  if (!img || !caption) return;

  img.src = src;
  img.alt = altText || "放大圖片";
  caption.textContent = altText || "";
  modal.classList.add("active");
}

function closeImageModal() {
  const modal = document.getElementById("imgModal");
  if (!modal) return;
  modal.classList.remove("active");

  const img = modal.querySelector(".img-modal__img");
  if (img) img.src = "";
}

document.addEventListener("click", (e) => {
  const target = e.target;
  if (!(target instanceof Element)) return;

  // 點圖片放大（避免小欄位難瀏覽）
  const modalRoot = target.closest("#imgModal");
  if (modalRoot) {
    closeImageModal();
    return;
  }

  const imgEl = target.closest("main img");
  if (imgEl instanceof HTMLImageElement && imgEl.src) {
    e.preventDefault();
    openImageModal(imgEl.currentSrc || imgEl.src, imgEl.alt || "");
    return;
  }

  const toggleBtn = target.closest('[data-action="toggle-menu"]');
  if (toggleBtn) {
    e.preventDefault();
    toggleOverlay();
    return;
  }

  const closeBtn = target.closest('[data-action="close-menu"]');
  if (closeBtn) {
    e.preventDefault();
    closeOverlay();
    return;
  }

  const navLink = target.closest("#navOverlay a");
  if (navLink) {
    closeOverlay();
    return;
  }

  const overlay = getOverlay();
  if (!overlay || !overlay.classList.contains("active")) return;

  if (!overlay.contains(target)) {
    closeOverlay();
  }
});

document.addEventListener("keydown", (e) => {
  if (e.key === "Escape") {
    closeOverlay();
    closeImageModal();
  }
});

function setupOverlayAutoCloseOnDesktop() {
  const mql = window.matchMedia && window.matchMedia("(min-width: 861px)");
  if (!mql) return;

  const onChange = () => {
    if (mql.matches) closeOverlay();
  };

  onChange();
  if ("addEventListener" in mql) {
    mql.addEventListener("change", onChange);
  } else if ("addListener" in mql) {
    mql.addListener(onChange);
  }
}

function setupHeaderScrollEffect() {
  const header = document.querySelector("header.site-header");
  if (!header) return;

  const onScroll = () => {
    const y = window.scrollY || 0;
    header.classList.toggle("is-scrolled", y > 8);
  };

  onScroll();
  window.addEventListener("scroll", onScroll, { passive: true });
}

function setupRevealOnScroll() {
  const prefersReducedMotion =
    window.matchMedia &&
    window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  const candidates = document.querySelectorAll(
    ".section, .section-header, .panel, .card, figure, .test-img, h1, .section-subtitle, .subtitle-line, .btn-row"
  );

  candidates.forEach((el) => el.classList.add("reveal"));

  if (prefersReducedMotion) {
    candidates.forEach((el) => el.classList.add("is-visible"));
    return;
  }

  if (!("IntersectionObserver" in window)) {
    candidates.forEach((el) => el.classList.add("is-visible"));
    return;
  }

  const io = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        entry.target.classList.add("is-visible");
        io.unobserve(entry.target);
      });
    },
    {
      root: null,
      threshold: 0.12,
      rootMargin: "0px 0px -10% 0px",
    }
  );

  candidates.forEach((el) => io.observe(el));
}

setupHeaderScrollEffect();
setupRevealOnScroll();
setupOverlayAutoCloseOnDesktop();
setMenuExpanded(false);
