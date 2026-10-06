import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideRouter, ActivatedRoute } from '@angular/router';
import { of, throwError } from 'rxjs';
import { OrderDetailPageComponent } from './order-detail-page.component';
import { OrdersService } from '../../../../core/services/orders.service';
import { CartOrder } from '../../../../core/models/order.model';

describe('OrderDetailPageComponent', () => {
  let component: OrderDetailPageComponent;
  let fixture: ComponentFixture<OrderDetailPageComponent>;
  let ordersServiceMock: jasmine.SpyObj<OrdersService>;

  const mockOrder: CartOrder = {
    id: 5,
    products: [
      {
        id: 101,
        title: 'Monitor 4K UHD',
        price: 400,
        quantity: 2,
        total: 800,
        discountPercentage: 10,
        discountedTotal: 720,
        thumbnail: 'https://example.com/monitor.jpg'
      }
    ],
    total: 800,
    discountedTotal: 720,
    userId: 88,
    totalProducts: 1,
    totalQuantity: 2
  };

  beforeEach(async () => {
    ordersServiceMock = jasmine.createSpyObj<OrdersService>('OrdersService', ['getOrderById']);
    ordersServiceMock.getOrderById.and.returnValue(of(mockOrder));

    await TestBed.configureTestingModule({
      imports: [OrderDetailPageComponent],
      providers: [
        provideRouter([]),
        { provide: OrdersService, useValue: ordersServiceMock },
        {
          provide: ActivatedRoute,
          useValue: {
            snapshot: {
              paramMap: {
                get: (key: string) => (key === 'id' ? '5' : null)
              }
            }
          }
        }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(OrderDetailPageComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('debe crearse correctamente el componente y consultar el pedido por ID', () => {
    expect(component).toBeTruthy();
    expect(ordersServiceMock.getOrderById).toHaveBeenCalledWith('5');
    expect(component.order()).toEqual(mockOrder);
    expect(component.loading()).toBeFalse();
  });

  it('debe renderizar el encabezado con el ID de pedido y el desglose de productos', () => {
    const compiled = fixture.nativeElement as HTMLElement;

    expect(compiled.textContent).toContain('Pedido #5');
    expect(compiled.textContent).toContain('Usuario #88');
    expect(compiled.textContent).toContain('Monitor 4K UHD');
    expect(compiled.textContent).toContain('$720.00');
  });

  it('debe manejar errores de carga desde el servicio', () => {
    ordersServiceMock.getOrderById.and.returnValue(throwError(() => new Error('Error de red')));
    component.loadOrderDetail('99');

    expect(component.errorMessage()).toContain('No se pudo cargar el detalle del pedido #99');
    expect(component.loading()).toBeFalse();
  });
});
