document.addEventListener('DOMContentLoaded', () => {
  const content = document.querySelector('.content');
  if (!content) {
    return;
  }

  const placeholderPattern = /(IMAGE IN THIS SECTION|IMAGES IN THIS SECTION|ENQUIRE NOW|GET IN TOUCH)/i;
  const firstTwoParagraphs = content.querySelectorAll('p:nth-of-type(-n+2)');

  // First two paragraphs duplicate the hero title/subtitle in converted docs.
  firstTwoParagraphs.forEach((p) => p.remove());

  const cleanText = (value) => value.replace(/\u00a0/g, ' ').replace(/\s+/g, ' ').trim();

  const slugify = (value) =>
    value
      .toLowerCase()
      .replace(/&/g, ' and ')
      .replace(/[^a-z0-9\s-]/g, '')
      .trim()
      .replace(/\s+/g, '-')
      .replace(/-+/g, '-');

  const normalize = (value) =>
    value
      .toLowerCase()
      .replace(/&/g, ' and ')
      .replace(/[^a-z0-9\s]/g, '')
      .replace(/\s+/g, ' ')
      .trim();

  const buildId = (value, fallback) => `${slugify(value) || fallback}`;

  const children = Array.from(content.children);
  children.forEach((node) => {
    if (node.tagName === 'P') {
      const text = cleanText(node.textContent || '');

      if (!text) {
        node.remove();
        return;
      }

      if (placeholderPattern.test(text)) {
        node.classList.add('image-placeholder');
      }
    }

    if (node.classList && node.classList.contains('Apple-converted-space')) {
      node.remove();
    }
  });

  // Convert contiguous bullet paragraphs into semantic unordered lists.
  const convertBulletParagraphs = (scope) => {
    const nodes = Array.from(scope.children);

    for (let i = 0; i < nodes.length; i += 1) {
      const node = nodes[i];
      if (!node || node.tagName !== 'P') {
        continue;
      }

      const text = cleanText(node.textContent || '');
      if (!text.startsWith('•')) {
        continue;
      }

      const ul = document.createElement('ul');
      ul.className = 'bullet-list';
      scope.insertBefore(ul, node);

      while (nodes[i] && nodes[i].tagName === 'P') {
        const current = nodes[i];
        const currentText = cleanText(current.textContent || '');

        if (!currentText.startsWith('•')) {
          break;
        }

        const li = document.createElement('li');
        li.innerHTML = current.innerHTML.replace(/^\s*•\s*/, '');
        ul.appendChild(li);
        current.remove();
        i += 1;
      }

      i -= 1;
    }
  };

  const enhanceFaqBlocks = (scope) => {
    const nodes = Array.from(scope.children);
    let currentFaqItem = null;

    nodes.forEach((node) => {
      if (node.tagName !== 'P') {
        currentFaqItem = null;
        return;
      }

      const text = cleanText(node.textContent || '');
      const isQuestion = /\?$/.test(text) && text.length <= 140;

      if (isQuestion) {
        const wrapper = document.createElement('div');
        wrapper.className = 'faq-item';
        scope.insertBefore(wrapper, node);
        wrapper.appendChild(node);
        node.classList.add('faq-question');
        currentFaqItem = wrapper;
        return;
      }

      if (currentFaqItem) {
        node.classList.add('faq-answer');
        currentFaqItem.appendChild(node);
      }
    });
  };

  const enhanceSteps = (scope) => {
    const paragraphs = Array.from(scope.querySelectorAll('p'));
    paragraphs.forEach((paragraph) => {
      const text = cleanText(paragraph.textContent || '');
      if (/^Step\s*\d+\./i.test(text)) {
        paragraph.classList.add('step-title');
      }
    });
  };

  const markLeadParagraph = (scope) => {
    const firstParagraph = scope.querySelector('p');
    if (firstParagraph) {
      firstParagraph.classList.add('section-lead');
    }
  };

  const wrapTables = (scope) => {
    scope.querySelectorAll('table').forEach((table) => {
      const wrap = document.createElement('div');
      wrap.className = 'table-wrap';
      table.parentNode.insertBefore(wrap, table);
      wrap.appendChild(table);
    });
  };

  const extractJumpLinks = (sectionEl, sectionMeta) => {
    if (!sectionMeta || sectionMeta.intro !== true) {
      return;
    }

    const titleMap = new Map();
    sectionMeta.allSections.forEach((entry) => {
      if (!entry.intro) {
        titleMap.set(normalize(entry.title), entry.id);
      }
    });

    const paragraphs = Array.from(sectionEl.children).filter((node) => node.tagName === 'P');
    const candidates = [];

    paragraphs.forEach((paragraph) => {
      const text = cleanText(paragraph.textContent || '');
      const looksLikeTocLine =
        text.length >= 14 &&
        text.length <= 120 &&
        !text.endsWith('.') &&
        !text.includes(':') &&
        !/^\(/.test(text) &&
        !/^Step\s*\d+/i.test(text) &&
        !/\?$/.test(text);

      if (looksLikeTocLine) {
        candidates.push({ paragraph, text });
      }
    });

    if (candidates.length < 4) {
      return;
    }

    const nav = document.createElement('nav');
    nav.className = 'jump-grid';
    nav.setAttribute('aria-label', 'Jump to key sections');

    candidates.forEach(({ paragraph, text }) => {
      const normalizedText = normalize(text);
      let targetId = titleMap.get(normalizedText);

      if (!targetId) {
        const match = Array.from(titleMap.entries()).find(([title]) =>
          title.includes(normalizedText) || normalizedText.includes(title)
        );
        if (match) {
          targetId = match[1];
        }
      }

      if (targetId) {
        const link = document.createElement('a');
        link.className = 'jump-link';
        link.textContent = text;
        link.href = `#${targetId}`;
        nav.appendChild(link);
      } else {
        const chip = document.createElement('span');
        chip.className = 'jump-link is-static';
        chip.textContent = text;
        nav.appendChild(chip);
      }

      paragraph.remove();
    });

    sectionEl.appendChild(nav);
  };

  const isHeadingParagraph = (node) => {
    if (!node || node.tagName !== 'P') {
      return false;
    }

    const text = cleanText(node.textContent || '');
    if (!text || text.length > 110) {
      return false;
    }

    const headingClass = node.classList.contains('p1') || node.classList.contains('p4');
    const looksBoldOnly = /^\s*<b[^>]*>.*<\/b>\s*$/i.test((node.innerHTML || '').trim());

    return headingClass || looksBoldOnly;
  };

  const contentNodes = Array.from(content.childNodes).filter((node) => {
    if (node.nodeType !== Node.ELEMENT_NODE) {
      return false;
    }

    if (node.classList.contains('local-nav')) {
      return false;
    }

    return true;
  });

  const sections = [];
  let currentSection = {
    title: 'Overview',
    nodes: [],
    intro: true,
  };

  contentNodes.forEach((node) => {
    if (isHeadingParagraph(node)) {
      if (currentSection.nodes.length) {
        sections.push(currentSection);
      }

      currentSection = {
        title: cleanText(node.textContent || 'Section'),
        nodes: [],
        intro: false,
      };
      node.remove();
      return;
    }

    currentSection.nodes.push(node);
  });

  if (currentSection.nodes.length) {
    sections.push(currentSection);
  }

  sections.forEach((entry, index) => {
    entry.id = buildId(entry.title || `section-${index + 1}`, `section-${index + 1}`);
  });

  sections.forEach((entry, index) => {
    // Prevent accidental duplicate ids when headings normalize similarly.
    const duplicatesBefore = sections.slice(0, index).filter((candidate) => candidate.id === entry.id).length;
    if (duplicatesBefore > 0) {
      entry.id = `${entry.id}-${duplicatesBefore + 1}`;
    }
  });

  const layout = document.createElement('div');
  layout.className = 'article-layout';

  const main = document.createElement('div');
  main.className = 'article-main';

  const rail = document.createElement('aside');
  rail.className = 'article-rail';

  const sectionNavCard = document.createElement('div');
  sectionNavCard.className = 'rail-card sticky';

  const sectionNavTitle = document.createElement('h2');
  sectionNavTitle.textContent = 'On This Page';
  sectionNavCard.appendChild(sectionNavTitle);

  const sectionNav = document.createElement('nav');
  sectionNav.className = 'section-nav';
  sectionNav.setAttribute('aria-label', 'Page section navigation');

  const localNav = content.querySelector('.local-nav');
  if (localNav) {
    const relatedCard = document.createElement('div');
    relatedCard.className = 'rail-card';
    relatedCard.appendChild(localNav);
    rail.appendChild(relatedCard);
  }

  sections.forEach((entry, index) => {
    const sectionEl = document.createElement('section');
    sectionEl.className = `content-section${entry.intro ? ' is-intro' : ''}`;
    sectionEl.classList.add('reveal-up');
    sectionEl.id = entry.id;

    if (!entry.intro) {
      const h2 = document.createElement('h2');
      h2.textContent = entry.title;
      sectionEl.appendChild(h2);
    }

    entry.nodes.forEach((node) => {
      sectionEl.appendChild(node);
    });

    markLeadParagraph(sectionEl);
    convertBulletParagraphs(sectionEl);
    wrapTables(sectionEl);
    enhanceSteps(sectionEl);
    enhanceFaqBlocks(sectionEl);
    extractJumpLinks(sectionEl, { intro: entry.intro, allSections: sections });

    main.appendChild(sectionEl);

    if (!entry.intro) {
      const link = document.createElement('a');
      link.href = `#${sectionEl.id}`;
      link.textContent = entry.title;
      link.dataset.targetId = sectionEl.id;
      sectionNav.appendChild(link);
    }
  });

  sectionNavCard.appendChild(sectionNav);
  sectionNavCard.classList.add('reveal-up');
  sectionNavCard.style.animationDelay = '80ms';
  rail.prepend(sectionNavCard);

  const railCards = Array.from(rail.querySelectorAll('.rail-card'));
  railCards.forEach((card, index) => {
    card.classList.add('reveal-up');
    card.style.animationDelay = `${Math.min(220, 80 + index * 60)}ms`;
  });

  layout.appendChild(main);
  layout.appendChild(rail);
  content.innerHTML = '';
  content.appendChild(layout);

  const observedSections = Array.from(main.querySelectorAll('.content-section[id]'));
  const sectionLinks = Array.from(sectionNav.querySelectorAll('a[data-target-id]'));

  if ('IntersectionObserver' in window && observedSections.length > 0 && sectionLinks.length > 0) {
    const sectionObserver = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) {
            return;
          }

          sectionLinks.forEach((link) => {
            const isTarget = link.dataset.targetId === entry.target.id;
            link.classList.toggle('is-active', isTarget);
          });
        });
      },
      {
        rootMargin: '-35% 0px -55% 0px',
        threshold: 0.01,
      }
    );

    observedSections.forEach((section) => sectionObserver.observe(section));
  }

  if ('IntersectionObserver' in window) {
    const revealObserver = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
            revealObserver.unobserve(entry.target);
          }
        });
      },
      {
        threshold: 0.14,
      }
    );

    document.querySelectorAll('.reveal-up').forEach((node) => revealObserver.observe(node));
  } else {
    document.querySelectorAll('.reveal-up').forEach((node) => node.classList.add('visible'));
  }
});
