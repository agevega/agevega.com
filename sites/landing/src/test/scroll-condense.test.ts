import { describe, it, expect } from 'vitest';
import { shouldCondense } from '../lib/scroll-condense';

describe('shouldCondense', () => {
  it('returns false at scrollY 0', () => {
    expect(shouldCondense(0)).toBe(false);
  });

  it('returns false at threshold (boundary inclusive)', () => {
    expect(shouldCondense(20)).toBe(false);
  });

  it('returns true above threshold', () => {
    expect(shouldCondense(21)).toBe(true);
  });

  it('respects custom threshold', () => {
    expect(shouldCondense(50, 100)).toBe(false);
    expect(shouldCondense(150, 100)).toBe(true);
  });
});
