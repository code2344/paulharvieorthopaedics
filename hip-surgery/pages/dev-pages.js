document.addEventListener('DOMContentLoaded', () => {
  const placeholderPattern = /(IMAGE IN THIS SECTION|IMAGES IN THIS SECTION|ENQUIRE NOW|GET IN TOUCH)/i;
  const firstTwoParagraphs = document.querySelectorAll('.content p:nth-of-type(-n+2)');

  firstTwoParagraphs.forEach((p) => p.remove());

  document.querySelectorAll('.content p').forEach((p) => {
    const text = (p.textContent || '').trim();
    if (!text) {
      p.remove();
      return;
    }
    if (placeholderPattern.test(text)) {
      p.classList.add('image-placeholder');
    }
  });
});
