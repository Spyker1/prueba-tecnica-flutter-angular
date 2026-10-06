import { DiscountPipe } from './discount.pipe';

describe('DiscountPipe', () => {
  const pipe = new DiscountPipe();

  it('debe crear la instancia del pipe', () => {
    expect(pipe).toBeTruthy();
  });

  it('debe calcular y formatear el porcentaje de descuento correctamente', () => {
    // Original: 100, Descuento: 85 -> 15% OFF
    const result = pipe.transform(100, 85);
    expect(result).toBe('-15% OFF');
  });

  it('debe formatear el monto de ahorro cuando se solicita formato "savings"', () => {
    // Original: 100, Descuento: 85 -> Ahorro: $15.00
    const result = pipe.transform(100, 85, 'savings');
    expect(result).toBe('Ahorro: $15.00');
  });

  it('debe formatear porcentaje directo cuando solo se pasa un número', () => {
    const result = pipe.transform(20);
    expect(result).toBe('-20% OFF');
  });

  it('debe formatear con formato "badge" incluyendo porcentaje y ahorro', () => {
    const result = pipe.transform(200, 150, 'badge');
    expect(result).toBe('-25% OFF · Ahorro: $50.00');
  });

  it('debe retornar cadena vacía si los valores son inválidos o no hay descuento', () => {
    expect(pipe.transform(0, 0)).toBe('');
    expect(pipe.transform(100, 100)).toBe('');
    expect(pipe.transform(null as any)).toBe('');
    expect(pipe.transform(undefined as any)).toBe('');
  });
});
