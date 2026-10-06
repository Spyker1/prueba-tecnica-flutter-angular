import { TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import {
  HttpTestingController,
  provideHttpClientTesting
} from '@angular/common/http/testing';
import { OrdersService } from './orders.service';
import { CartsApiResponse } from '../models/order.model';

describe('OrdersService', () => {
  let service: OrdersService;
  let httpTestingController: HttpTestingController;

  const mockApiResponse: CartsApiResponse = {
    carts: [
      {
        id: 1,
        products: [
          {
            id: 10,
            title: 'Wireless Mouse',
            price: 25.0,
            quantity: 2,
            total: 50.0,
            discountPercentage: 10,
            discountedTotal: 45.0,
            thumbnail: 'https://example.com/mouse.jpg'
          }
        ],
        total: 50.0,
        discountedTotal: 45.0,
        userId: 99,
        totalProducts: 1,
        totalQuantity: 2
      }
    ],
    total: 1,
    skip: 0,
    limit: 10
  };

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        OrdersService,
        provideHttpClient(),
        provideHttpClientTesting()
      ]
    });

    service = TestBed.inject(OrdersService);
    httpTestingController = TestBed.inject(HttpTestingController);
  });

  afterEach(() => {
    httpTestingController.verify();
  });

  it('debe crearse correctamente el servicio', () => {
    expect(service).toBeTruthy();
  });

  it('debe realizar una petición GET a https://dummyjson.com/carts y retornar la lista de pedidos tipada', () => {
    service.getOrders().subscribe((response: CartsApiResponse) => {
      expect(response).toEqual(mockApiResponse);
      expect(response.carts.length).toBe(1);
      expect(response.carts[0].id).toBe(1);
      expect(response.carts[0].discountedTotal).toBe(45.0);
    });

    const req = httpTestingController.expectOne('https://dummyjson.com/carts');
    expect(req.request.method).toBe('GET');
    req.flush(mockApiResponse);
  });
});
