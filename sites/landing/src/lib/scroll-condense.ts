export function shouldCondense(scrollY: number, threshold = 20): boolean {
  return scrollY > threshold;
}
