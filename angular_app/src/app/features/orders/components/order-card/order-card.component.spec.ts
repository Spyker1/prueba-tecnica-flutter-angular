import { ComponentFixture, TestBed } from '@angular/core/testing';
import { OrderCardComponent } from './order-card.component';
import { CartOrder } from '../../../../core/models/order.model';

describe('OrderCardComponent', () => {
  let component: OrderCardComponent;
  let fixture: ComponentFixture<OrderCardComponent>;

  const mockOrder: CartOrder = {
    id: 42,
    products: [
      {
        id: 1,
        title: 'Teclado Mecánico',
        price: 100,
        quantity: 1,
        total: 100,
        discountPercentage: 15,
        discountedTotal: 85,
        thumbnail: 'https://example.com/keyboard.jpg'
      }
    ],
    total: 100,
    discountedTotal: 85,
    userId: 12,
    totalProducts: 1,
    totalQuantity: 1
  };

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [OrderCardComponent]
    }).compileComponents();

    fixture = TestBed.createComponent(OrderCardComponent);
    component = fixture.componentInstance;
    fixture.componentRef.setInput('order', mockOrder);
    fixture.detectChanges();
  });

  it('debe crear el componente correctamente', () => {
    expect(component).toBeTruthy();
  });

  it('debe renderizar correctamente el ID del pedido y el total con descuento', () => {
    const compiled = fixture.nativeElement as HTMLElement;

    // Verifica que el ID del pedido esté presente en el DOM
    expect(compiled.textContent).toContain('Pedido #42');

    // Verifica que el total con descuento formateado esté presente en el DOM
    expect(compiled.textContent).toContain('$85.00');
  });

  it('debe emitir el ID del pedido a través del evento de salida al hacer clic en "Ver Detalle"', () => {
    let emittedId: number | undefined;
    let emittedOrder: CartOrder | undefined;

    component.viewDetail.subscribe((order: CartOrder) => {
      emittedOrder = order;
      emittedId = order.id;
    });

    const button = fixture.nativeElement.querySelector('.detail-button') as HTMLButtonElement;
    expect(button).toBeTruthy();
    button.click();

    // Comprueba que el evento de salida emita el ID del pedido esperado (42) y el objeto completo
    expect(emittedId).toBe(42);
    expect(emittedOrder).toEqual(mockOrder);
  });
});
