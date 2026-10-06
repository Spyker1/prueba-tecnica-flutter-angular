import { ComponentFixture, TestBed } from '@angular/core/testing';
import { of, throwError } from 'rxjs';
import { OrdersPageComponent } from './orders-page.component';
import { OrdersService } from '../../../../core/services/orders.service';
import { CartsApiResponse } from '../../../../core/models/order.model';

describe('OrdersPageComponent', () => {
  let component: OrdersPageComponent;
  let fixture: ComponentFixture<OrdersPageComponent>;
  let ordersServiceMock: jasmine.SpyObj<OrdersService>;

  const mockResponse: CartsApiResponse = {
    carts: [
      {
        id: 1,
        products: [],
        total: 500,
        discountedTotal: 400,
        userId: 10,
        totalProducts: 2,
        totalQuantity: 4
      },
      {
        id: 2,
        products: [],
        total: 1200,
        discountedTotal: 1000,
        userId: 20,
        totalProducts: 5,
        totalQuantity: 8
      },
      {
        id: 3,
        products: [],
        total: 6000,
        discountedTotal: 5000,
        userId: 30,
        totalProducts: 1,
        totalQuantity: 1
      }
    ],
    total: 3,
    skip: 0,
    limit: 10
  };

  beforeEach(async () => {
    ordersServiceMock = jasmine.createSpyObj<OrdersService>('OrdersService', ['getOrders']);
    ordersServiceMock.getOrders.and.returnValue(of(mockResponse));

    await TestBed.configureTestingModule({
      imports: [OrdersPageComponent],
      providers: [
        { provide: OrdersService, useValue: ordersServiceMock }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(OrdersPageComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create the component and load orders on init', () => {
    expect(component).toBeTruthy();
    expect(ordersServiceMock.getOrders).toHaveBeenCalled();
    expect(component.orders().length).toBe(3);
    expect(component.loading()).toBeFalse();
    expect(component.errorMessage()).toBeNull();
  });

  it('should filter orders reactively using computed signal minTotalFilter', () => {
    // Inicialmente con minTotalFilter = 0, se muestran todas las órdenes (3)
    expect(component.filteredOrders().length).toBe(3);

    // Filtrar con mínimo $1,000 -> órdenes con discountedTotal >= 1000 (orden 2 y orden 3)
    component.minTotalFilter.set(1000);
    expect(component.filteredOrders().length).toBe(2);
    expect(component.filteredOrders().map(o => o.id)).toEqual([2, 3]);

    // Filtrar con mínimo $5,000 -> solo orden 3
    component.minTotalFilter.set(5000);
    expect(component.filteredOrders().length).toBe(1);
    expect(component.filteredOrders()[0].id).toBe(3);

    // Filtrar con monto muy alto -> 0 resultados
    component.minTotalFilter.set(100000);
    expect(component.filteredOrders().length).toBe(0);

    // Restablecer filtro
    component.resetFilter();
    expect(component.minTotalFilter()).toBe(0);
    expect(component.filteredOrders().length).toBe(3);
  });

  it('should manage selectedOrder signal when opening and closing details', () => {
    expect(component.selectedOrder()).toBeNull();

    // Seleccionar orden 2
    const targetOrder = mockResponse.carts[1];
    component.onSelectOrder(targetOrder);
    expect(component.selectedOrder()).toEqual(targetOrder);

    // Cerrar detalle
    component.closeDetail();
    expect(component.selectedOrder()).toBeNull();
  });

  it('should handle API errors by setting errorMessage signal', () => {
    ordersServiceMock.getOrders.and.returnValue(throwError(() => new Error('Network error')));
    component.loadOrders();

    expect(component.errorMessage()).toContain('Error al cargar el listado de pedidos');
    expect(component.loading()).toBeFalse();
  });
});
