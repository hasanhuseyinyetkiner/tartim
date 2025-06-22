using CYS.Data;
using CYS.Models;
using CYS.Models.DTOs;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace CYS.Repos
{
    public class WeightMeasurementRepository
    {
        private readonly ApplicationDbContext _context;

        public WeightMeasurementRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<List<WeightMeasurementDTO>> GetAllWeightMeasurementsAsync()
        {
            return await _context.WeightMeasurements
                .Include(w => w.Animal)
                .Select(w => new WeightMeasurementDTO
                {
                    Id = w.Id,
                    AnimalId = w.AnimalId,
                    Weight = w.Weight,
                    MeasurementDate = w.MeasurementDate,
                    RFID = w.RFID,
                    Notes = w.Notes,
                    UserId = w.UserId,
                    AnimalName = w.Animal != null ? w.Animal.Name : null,
                    AnimalEarTag = w.Animal != null ? w.Animal.EarTag : null,
                    AnimalType = w.Animal != null ? w.Animal.Type : null
                })
                .OrderByDescending(w => w.MeasurementDate)
                .ToListAsync();
        }

        public async Task<List<WeightMeasurementDTO>> GetWeightMeasurementsByAnimalIdAsync(int animalId)
        {
            return await _context.WeightMeasurements
                .Include(w => w.Animal)
                .Where(w => w.AnimalId == animalId)
                .Select(w => new WeightMeasurementDTO
                {
                    Id = w.Id,
                    AnimalId = w.AnimalId,
                    Weight = w.Weight,
                    MeasurementDate = w.MeasurementDate,
                    RFID = w.RFID,
                    Notes = w.Notes,
                    UserId = w.UserId,
                    AnimalName = w.Animal != null ? w.Animal.Name : null,
                    AnimalEarTag = w.Animal != null ? w.Animal.EarTag : null,
                    AnimalType = w.Animal != null ? w.Animal.Type : null
                })
                .OrderByDescending(w => w.MeasurementDate)
                .ToListAsync();
        }

        public async Task<List<WeightMeasurementDTO>> GetWeightMeasurementsByRfidAsync(string rfid)
        {
            return await _context.WeightMeasurements
                .Include(w => w.Animal)
                .Where(w => w.RFID == rfid)
                .Select(w => new WeightMeasurementDTO
                {
                    Id = w.Id,
                    AnimalId = w.AnimalId,
                    Weight = w.Weight,
                    MeasurementDate = w.MeasurementDate,
                    RFID = w.RFID,
                    Notes = w.Notes,
                    UserId = w.UserId,
                    AnimalName = w.Animal != null ? w.Animal.Name : null,
                    AnimalEarTag = w.Animal != null ? w.Animal.EarTag : null,
                    AnimalType = w.Animal != null ? w.Animal.Type : null
                })
                .OrderByDescending(w => w.MeasurementDate)
                .ToListAsync();
        }

        public async Task<WeightMeasurementDTO> GetWeightMeasurementByIdAsync(int id)
        {
            var measurement = await _context.WeightMeasurements
                .Include(w => w.Animal)
                .FirstOrDefaultAsync(w => w.Id == id);

            if (measurement == null)
                return null;

            return new WeightMeasurementDTO
            {
                Id = measurement.Id,
                AnimalId = measurement.AnimalId,
                Weight = measurement.Weight,
                MeasurementDate = measurement.MeasurementDate,
                RFID = measurement.RFID,
                Notes = measurement.Notes,
                UserId = measurement.UserId,
                AnimalName = measurement.Animal?.Name,
                AnimalEarTag = measurement.Animal?.EarTag,
                AnimalType = measurement.Animal?.Type
            };
        }

        public async Task<int> AddWeightMeasurementAsync(WeightMeasurementDTO measurementDto)
        {
            var measurement = new WeightMeasurement
            {
                AnimalId = measurementDto.AnimalId,
                Weight = measurementDto.Weight,
                MeasurementDate = measurementDto.MeasurementDate,
                RFID = measurementDto.RFID,
                Notes = measurementDto.Notes,
                UserId = measurementDto.UserId,
                CreatedAt = DateTime.Now
            };

            _context.WeightMeasurements.Add(measurement);
            await _context.SaveChangesAsync();

            return measurement.Id;
        }

        public async Task<bool> UpdateWeightMeasurementAsync(int id, WeightMeasurementDTO measurementDto)
        {
            var measurement = await _context.WeightMeasurements.FindAsync(id);

            if (measurement == null)
                return false;

            measurement.AnimalId = measurementDto.AnimalId;
            measurement.Weight = measurementDto.Weight;
            measurement.MeasurementDate = measurementDto.MeasurementDate;
            measurement.RFID = measurementDto.RFID;
            measurement.Notes = measurementDto.Notes;
            measurement.UpdatedAt = DateTime.Now;

            _context.WeightMeasurements.Update(measurement);
            await _context.SaveChangesAsync();

            return true;
        }

        public async Task<bool> DeleteWeightMeasurementAsync(int id)
        {
            var measurement = await _context.WeightMeasurements.FindAsync(id);
            
            if (measurement == null)
                return false;
                
            _context.WeightMeasurements.Remove(measurement);
            await _context.SaveChangesAsync();
            
            return true;
        }
    }
} 